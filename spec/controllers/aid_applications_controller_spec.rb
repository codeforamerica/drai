require 'rails_helper'

describe AidApplicationsController, type: :controller do
  let(:admin) { create :admin }
  let!(:application1) { create :aid_application, :submitted }
  let!(:application2) { create :aid_application }

  describe '#index' do
    context 'when an admin' do
      before { sign_in admin }

      it 'shows all aid applications created' do
        get :index

        expect(response).to have_http_status :ok
        expect(assigns(:aid_applications)).to contain_exactly(application1, application2)
      end
    end
  end
end