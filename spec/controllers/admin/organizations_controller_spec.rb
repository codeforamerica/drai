require 'rails_helper'

describe Admin::OrganizationsController do
  let(:assister) { create :assister }
  let(:other_assister) { create :assister }
  let(:admin) { create :admin }

  describe '#index' do
    context 'when a assister' do
      before { sign_in assister }

      it 'is not accessible' do
        get :index
        expect(response).to have_http_status :found
      end
    end

    context 'when an admin' do
      before { sign_in admin }

      it 'is accessible' do
        get :index
        expect(response).to have_http_status :ok
      end
    end
  end
end
