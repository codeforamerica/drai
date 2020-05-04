require 'rails_helper'

RSpec.describe AidApplication, type: :model do
  let(:aid_application) { create :aid_application }

  it 'has a valid factory' do
    aid_application = build :aid_application, members_count: 1
    expect(aid_application).to be_valid(:submit)
  end

  describe '#organization' do
    it 'is required' do
      aid_application.organization = nil
      expect(aid_application).not_to be_valid
      expect(aid_application.errors[:organization]).to include("must exist")
    end
  end

  describe '#creator' do
    it 'is required' do
      aid_application.creator = nil
      expect(aid_application).not_to be_valid
      expect(aid_application.errors[:creator]).to include("must exist")
    end
  end

  describe '#street_address' do
    it 'is required' do
      aid_application = build :aid_application, street_address: ''
      expect(aid_application).not_to be_valid(:submit)
    end
  end

  describe '#city' do
    it 'is required' do
      aid_application = build :aid_application, city: ''
      expect(aid_application).not_to be_valid(:submit)
    end
  end

  describe '#zip_code' do
    it 'is required' do
      aid_application = build :aid_application, zip_code: ''
      expect(aid_application).not_to be_valid(:submit)
    end
    it 'must be valid' do
      aid_application = build :aid_application, zip_code: 'none'
      expect(aid_application).not_to be_valid(:submit)
    end
    it 'cannot be outside of california' do
      aid_application = build :aid_application, zip_code: '89101'
      expect(aid_application).not_to be_valid(:submit)
    end
  end

  describe '#phone_number' do
    context 'when preferred_contact_channel is either text or voice' do
      it 'is required' do
        aid_application = build :aid_application, phone_number: '', preferred_contact_channel: 'text'
        expect(aid_application).not_to be_valid(:submit)
      end

      it 'must be a valid number' do
        aid_application = build :aid_application, phone_number: '111', preferred_contact_channel: 'voice'
        expect(aid_application).not_to be_valid(:submit)
      end

      it 'allows intermediate characters' do
        aid_application = build :aid_application, phone_number: '+1-555-666.1234', preferred_contact_channel: 'text'
        expect(aid_application).to be_valid(:submit)
        expect(aid_application.phone_number).to eq '5556661234'
      end
    end

    context 'when preferred_contact_channel is NEITHER text NOR voice' do
      it 'is not required' do
        aid_application = build :aid_application, phone_number: '', preferred_contact_channel: 'email', email: "hi@example.com"
        expect(aid_application).to be_valid(:submit)
      end
    end
  end

  describe '#email' do
    context 'when preferred_contacted_mode is email' do
      it 'is required' do
        aid_application = build :aid_application, email: '', preferred_contact_channel: 'email'
        expect(aid_application).not_to be_valid(:submit)
      end

      it 'must be valid' do
        aid_application = build :aid_application, email: '@garbage', preferred_contact_channel: 'email'
        expect(aid_application).not_to be_valid(:submit)
      end
    end

    context 'when preferred_contacted_mode is NOT email' do
      it 'is not required' do
        aid_application = build :aid_application, email: '', preferred_contact_channel: 'text'
        expect(aid_application).to be_valid(:submit)
      end
    end
  end

  describe '#members' do
    it 'must have at least 1' do
      aid_application = build :aid_application, members_count: 0
      expect(aid_application).not_to be_valid(:submit)
    end

    it 'must not have more than 2' do
      aid_application = build :aid_application, members_count: 3
      expect(aid_application).not_to be_valid(:submit)
    end
  end

  describe '.member_names' do
    it 'returns an array of member names' do
      aid_application = build :aid_application, members_count: 1
      expect(aid_application.member_names).to contain_exactly(aid_application.members[0].name)
    end
  end

  describe '.query', truncate: :database do
    it 'performs a scoped query against associated AidApplicationSearch' do
      aid_application = create :aid_application
      other_aid_application = create :aid_application, city: 'Riverside'

      refresh_materialized_views do
        expect(described_class.query('Riverside')).to eq [other_aid_application]
      end
    end
  end

  private

  def refresh_materialized_views
    AidApplicationSearch.refresh
    yield
  end

  describe '#trigger_submit' do
    let(:aid_application) { create :aid_application }

    it 'adds a submitted_at' do
      expect {
        aid_application.save_and_submit(submitter: aid_application.creator)
      }.to change { aid_application.reload.submitted_at }.from(nil).to within(1.second).of Time.current
    end

    it 'generates a application_number' do
      expect {
        aid_application.save_and_submit(submitter: aid_application.creator)
      }.to change { aid_application.reload.application_number.present? }.from(false).to true
    end
  end

  describe '#aid_identifier' do
    it 'cannot be changed once assigned' do
      aid_application = create :aid_application, :submitted
      expect do
        aid_application.update application_number: 'something else'
      end.not_to change { aid_application.reload.application_number }
    end
  end

  describe '#generate_unique_identifer' do
    let(:aid_application) { create :aid_application }

    it 'is in the shape of APP-[organization_id]-123-456' do
      expect(aid_application.generate_application_number).to match /APP-#{aid_application.organization.id}-\d{3}-\d{3}/
    end

    it 'cycles through values until it finds a valid one' do
      tried_values = []
      allow(described_class).to receive :exists? do |**args|
        tried_values << args[:application_number]
        tried_values.size < 4 ? true : false
      end

      aid_application.generate_application_number

      expect(tried_values.uniq.size).to eq 4
    end
  end
end
