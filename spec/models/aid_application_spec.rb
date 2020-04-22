require 'rails_helper'

RSpec.describe AidApplication, type: :model do
  let(:aid_application) { create :aid_application }

  it 'has a valid factory' do
    expect(aid_application).to be_valid
  end

  describe '#organization' do
    it 'is required' do
      aid_application.organization = nil
      expect(aid_application).not_to be_valid
      expect(aid_application.errors[:organization]).to include("must exist")
    end
  end

  describe '#assister' do
    it 'is required' do
      aid_application.assister = nil
      expect(aid_application).not_to be_valid
      expect(aid_application.errors[:assister]).to include("must exist")
    end
  end

  describe '#street_address' do
    it 'is required' do
      aid_application = build :aid_application, street_address: ''
      expect(aid_application).not_to be_valid
    end
  end

  describe '#city' do
    it 'is required' do
      aid_application = build :aid_application, city: ''
      expect(aid_application).not_to be_valid
    end
  end

  describe '#zip_code' do
    it 'is required' do
      aid_application = build :aid_application, zip_code: ''
      expect(aid_application).not_to be_valid
    end
    it 'must be valid' do
      aid_application = build :aid_application, zip_code: 'none'
      expect(aid_application).not_to be_valid
    end
    it 'cannot be outside of california' do
      aid_application = build :aid_application, zip_code: '89101'
      expect(aid_application).not_to be_valid
    end
  end

  describe '#phone_number' do
    it 'is required' do
      aid_application = build :aid_application, phone_number: ''
      expect(aid_application).not_to be_valid
    end
    it 'must be a valid number' do
      aid_application = build :aid_application, phone_number: '111'
      expect(aid_application).not_to be_valid
    end

    it 'allows intermediate characters' do
      aid_application = build :aid_application, phone_number: '+1-555-666.1234'
      expect(aid_application).to be_valid
      expect(aid_application.phone_number).to eq '5556661234'
    end
  end

  describe '#email' do
    it 'is required' do
      aid_application = build :aid_application, email: ''
      expect(aid_application).not_to be_valid
    end

    it 'must be valid' do
      aid_application = build :aid_application, email: '@garbage'
      expect(aid_application).not_to be_valid
    end
  end

  describe '#members' do
    it 'must have at least 1' do
      aid_application = build :aid_application, members_count: 0
      expect(aid_application).not_to be_valid
    end

    it 'must not have more than 2' do
      aid_application = build :aid_application, members_count: 3
      expect(aid_application).not_to be_valid
    end
  end
end
