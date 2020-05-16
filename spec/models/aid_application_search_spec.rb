require 'rails_helper'

RSpec.describe AidApplicationSearch, type: :model do
  let!(:aid_application) { create :aid_application, :submitted }
  let!(:unsubmitted_aid_application) { create :aid_application}

  before do
    described_class.refresh
  end

  def apps_for_search(term)
    described_class.search(term).map(&:aid_application)
  end

  describe '#search' do
    it 'only indexes applications with an application_number' do
      expect(apps_for_search(unsubmitted_aid_application.name)).not_to include(unsubmitted_aid_application)
    end

    it 'returns applications with a matching application number' do
      expect(apps_for_search(aid_application.application_number)).to contain_exactly(aid_application)
    end

    it 'returns applications with a matching name' do
      expect(apps_for_search(aid_application.name)).to include(aid_application)
    end

    it 'returns applications with a matching city' do
      expect(apps_for_search(aid_application.city)).to include(aid_application)
    end

    it 'returns applications with a matching zip code' do
      expect(apps_for_search(aid_application.zip_code)).to include(aid_application)
    end
  end
end
