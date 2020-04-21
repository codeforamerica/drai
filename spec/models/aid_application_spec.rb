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
end
