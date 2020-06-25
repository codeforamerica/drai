require 'rails_helper'

RSpec.describe Organization, type: :model do
  it 'has a valid factory' do
    organization = build :organization
    expect(organization).to be_valid
  end

  describe '.with_counts' do
    let(:organization) { create :organization }
    let(:organization_with_counts) { Organization.with_counts.find organization.id }

    let!(:unsubmitted_apps) { create_list :aid_application, 2, organization: organization }
    let!(:submitted_apps) { create_list :aid_application, 3, :submitted, organization: organization }

    it 'is separate from counter_cache' do
      expect(organization.aid_applications_count).to eq 5
    end

    it 'returns the counts of number of active applications' do
      expect(organization_with_counts.submitted_aid_applications_count).to eq 3
    end
  end

  describe 'papertrail' do
    let(:organization) { create :organization }

    it 'tracks changes' do
      expect do
        organization.update name: "something else"
      end.to change { organization.reload.versions.count }.by(1)
    end
  end

  describe '#counts_by_county' do
    let(:organization) { create :organization, county_names: ['San Francisco', 'Marin'], total_payment_cards_count: 8 }

    let!(:marin_disbursed) { create_list :aid_application, 3, :disbursed, organization: organization, county_name: 'Marin', zip_code: '94903' }

    let!(:sf_approved) { create_list :aid_application, 1, :approved, organization: organization, county_name: 'San Francisco', zip_code: '94108' }
    let!(:sf_paused) { create_list :aid_application, 1, :paused, organization: organization, county_name: 'San Francisco', zip_code: '94108' }
    let!(:sf_unpaused) { create_list :aid_application, 1, :unpaused, organization: organization, county_name: 'San Francisco', zip_code: '94108' }
    let!(:sf_submitted) { create_list :aid_application, 1, :submitted, organization: organization, county_name: 'San Francisco', zip_code: '94108' }
    let!(:sf_rejected) { create_list :aid_application, 2, :rejected, organization: organization, county_name: 'San Francisco', zip_code: '94108' }
    let!(:sm_submitted) { create_list :aid_application, 3, :submitted, organization: organization, county_name: 'San Mateo', zip_code: '94401' }

    before do
      AidApplicationWaitlist.refresh
    end

    it 'returns each county with individual counts' do
      expect(organization.counts_by_county).to eq({
                                                    "Marin" => {
                                                      submitted: 0,
                                                      paused: 0,
                                                      approved: 0,
                                                      disbursed: 3,
                                                      rejected: 0,
                                                      waitlisted: 0,
                                                      total: 3,
                                                    },
                                                    "San Francisco" => {
                                                      submitted: 2,
                                                      paused: 1,
                                                      approved: 1,
                                                      disbursed: 0,
                                                      total: 4,
                                                      rejected: 2,
                                                      waitlisted: 0,
                                                    },
                                                    "San Mateo" => {
                                                      submitted: 1,
                                                      paused: 0,
                                                      approved: 0,
                                                      disbursed: 0,
                                                      total: 1,
                                                      rejected: 0,
                                                      waitlisted: 2,
                                                    },
                                                    'Total' => {
                                                      submitted: 3,
                                                      paused: 1,
                                                      approved: 1,
                                                      disbursed: 3,
                                                      total: 8,
                                                      rejected: 2,
                                                      waitlisted: 2,
                                                    }
                                                  })
    end
  end

  describe '#contact_information_for_county' do
    context 'when contact_information is just a phone number' do
      let(:org) { create :organization, contact_information: '555-555-5555' }
      it 'returns the contact information' do
        expect(org.contact_information_for_county('San Francisco')).to eq '555-555-5555'
      end
    end

    context 'when contact_information contains a slash with multiple counties' do
      let(:org) { create :organization, contact_information: 'San Mateo County: 555-555-5555 / San Francisco County: 666-666-6666' }

      it 'returns the contact information' do
        expect(org.contact_information_for_county('San Mateo')).to eq '555-555-5555'
        expect(org.contact_information_for_county('San Francisco')).to eq '666-666-6666'
      end
    end
  end

  describe '#submission_instructions' do
    context 'for an organization with only one county' do
      let(:org) { create :organization, name: 'CHIRLA', slug: 'chirla' }

      it 'just has the simple info' do
        result = org.submission_instructions(application_number: 'APP-1-12345', county: 'San Francisco', locale: 'en')

        expect(result).to be_present
        expect(result).to eq I18n.t('submission_instructions.chirla', application_number: 'APP-1-12345', locale: 'en')
      end
    end

    context 'for an organization with multiple counties' do
      let(:org) { create :organization, name: 'MICOP', slug: 'micop', county_names: ['Santa Barbara', 'Ventura'] }

      it 'just has the correct county' do
        result = org.submission_instructions(application_number: 'APP-1-12345', county: 'Santa Barbara', locale: 'en')

        expect(result).to be_present
        expect(result).to eq I18n.t('submission_instructions.micop.santa_barbara', application_number: 'APP-1-12345', locale: 'en')

        default_result = org.submission_instructions(application_number: 'APP-1-12345', county: 'Ventura', locale: 'en')

        expect(default_result).to be_present
        expect(default_result).to eq I18n.t('submission_instructions.micop.ventura', application_number: 'APP-1-12345', locale: 'en')
      end
    end

    context 'for an organization without a custom message' do
      let(:org) { create :organization, name: 'UFW', slug: 'cabsc', contact_information: '555-555-5555' }

      it 'uses the default message' do
        result = org.submission_instructions(application_number: 'APP-1-12345', county: 'Contra Costa', locale: 'en')

        expect(result).to be_present
        expect(result).to eq I18n.t('submission_instructions.default', application_number: 'APP-1-12345', contact_information: '555-555-5555', locale: 'en')
      end
    end
  end
end
