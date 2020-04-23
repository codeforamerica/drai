require 'rails_helper'

RSpec.describe AidApplicationSearch, type: :model do
  def apps_for_search(term)
    described_class.search(term).map(&:aid_application)
  end

  describe '#search' do
    it 'returns applications with a matching id number' do
      aid_application = create :aid_application

      refresh_materialized_view do
        expect(apps_for_search(aid_application.id)).to include(aid_application)
      end
    end
    it 'returns applications with a matching name' do
      member = create(:member)

      refresh_materialized_view do
        expect(apps_for_search(member.name)).to include(member.aid_application)
      end
    end
    it 'returns applications with a matching city' do
      aid_application = create(:aid_application)

      refresh_materialized_view do
        expect(apps_for_search(aid_application.city)).to include(aid_application)
      end
    end
    it 'returns applications with a matching zip code' do
      aid_application = create(:aid_application)

      refresh_materialized_view do
        expect(apps_for_search(aid_application.zip_code)).to include(aid_application)
      end
    end
  end

  private

  def refresh_materialized_view
    described_class.refresh
    yield
  end
end
