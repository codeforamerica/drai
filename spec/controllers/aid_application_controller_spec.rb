require 'rails_helper'

describe AidApplicationsController, type: :controller do
  let(:admin) { create :admin }
  let!(:application1) { create :aid_application }
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

    context 'when an assister' do
      before { sign_in application1.assister }

      it 'does not allow access to the All Applications View' do
        get :index
        expect(response).to have_http_status :found
      end

      it "shows all aid applications in the assister's organization" do
        get :index, params: { organization_id: application1.organization_id }

        expect(response).to have_http_status :ok
        expect(assigns(:aid_applications)).to contain_exactly(application1)
      end
    end
  end

  describe '#create' do
    let(:assister) { create :assister }

    before { sign_in assister }

    it 'creates an empty AidApplication and redirects to the edit it' do
      expect do
        post :create, params: { organization_id: assister.organization.id }
      end.to change(AidApplication, :count).by 1

      aid_application = AidApplication.last
      expect(aid_application).to have_attributes(
                                       assister: assister,
                                       organization: assister.organization
                                     )
      expect(response).to redirect_to edit_organization_aid_application_edit_path(assister.organization, aid_application)
    end
  end
end
