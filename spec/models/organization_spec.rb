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
end
