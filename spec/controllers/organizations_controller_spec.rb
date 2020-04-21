require 'rails_helper'

describe OrganizationsController do
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

  describe '#show' do
    context 'when an assister' do
      before { sign_in assister }

      it 'returns a 200 status' do
        get :show, params: { id: assister.organization.id }
        expect(response).to have_http_status :ok
      end
    end

    context 'when an assister in a different organization' do
      before { sign_in other_assister }

      it 'is redirected away' do
        get :show, params: { id: assister.organization.id }
        expect(response).to have_http_status :found
      end
    end

    context 'when an admin' do
      before { sign_in admin }

      it 'returns a 200 status' do
        get :show, params: { id: assister.organization.id }
        expect(response).to have_http_status :ok
      end
    end
  end
end
