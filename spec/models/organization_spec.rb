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
    let(:organization) { create :organization, county_names: ['San Francisco', 'Marin'] }

    let!(:sf_submitted) { create_list :aid_application, 3, :submitted, organization: organization, county_name: 'San Francisco', zip_code: '94108' }
    let!(:sf_approved) { create_list :aid_application, 3, :approved, organization: organization, county_name: 'San Francisco', zip_code: '94108' }
    let!(:sf_rejected) { create_list :aid_application, 2, :rejected, organization: organization, county_name: 'San Francisco', zip_code: '94108' }
    let!(:sf_paused) { create_list :aid_application, 2, :paused, organization: organization, county_name: 'San Francisco', zip_code: '94108' }
    let!(:sf_unpaused) { create_list :aid_application, 2, :unpaused, organization: organization, county_name: 'San Francisco', zip_code: '94108' }
    let!(:marin_disbursed) { create_list :aid_application, 3, :disbursed, organization: organization, county_name: 'Marin', zip_code: '94903' }
    let!(:sm_submitted) { create_list :aid_application, 3, :submitted, organization: organization, county_name: 'San Mateo', zip_code: '94401' }

    it 'returns each county with individual counts' do
      expect(organization.counts_by_county).to eq({
                                                    "Marin" => {
                                                      submitted: 0,
                                                      approved: 0,
                                                      disbursed: 3,
                                                      paused: 0,
                                                      rejected: 0,
                                                      total: 3
                                                    },
                                                    "San Francisco" => {
                                                      submitted: 5,
                                                      approved: 3,
                                                      disbursed: 0,
                                                      paused: 2,
                                                      rejected: 2,
                                                      total: 8,
                                                    },
                                                    "San Mateo" => {
                                                      submitted: 3,
                                                      approved: 0,
                                                      disbursed: 0,
                                                      paused: 0,
                                                      rejected: 0,
                                                      total: 3
                                                    },
                                                  })
    end
  end
end
