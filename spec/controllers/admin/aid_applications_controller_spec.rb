require 'rails_helper'

describe Admin::AidApplicationsController, type: :controller do
  let(:admin) { create :admin }
  let!(:submitted_application) { create :aid_application, :submitted }
  let!(:unsubmitted_application) { create :aid_application }

  describe '#index' do
    context 'when an admin' do
      before { sign_in admin }

      it 'shows all aid applications created' do
        get :index

        expect(response).to have_http_status :ok
        expect(assigns(:aid_applications)).to contain_exactly(submitted_application)
      end

      it 'has working search' do
        get :index, params: { term: 'something' }

        expect(response).to have_http_status :ok
      end
    end
  end
end
