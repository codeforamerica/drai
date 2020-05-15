require 'rails_helper'

describe AidApplications::VerificationsController do
  let(:assister) { create :assister }
  let(:aid_application) { AidApplication.create!(creator: assister, organization: assister.organization) }

  describe '#edit' do
    context 'when not authenticated' do
      it 'does not allow access' do
        get :edit, params: {
            aid_application_id: aid_application.id,
            organization_id: assister.organization.id,
        }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#update' do
    let(:assister) { create :assister }
    let(:aid_application) { AidApplication.create!(creator: assister, organization: assister.organization) }

    before do
      sign_in aid_application.creator

      put :update, params: {
          aid_application_id: aid_application.id,
          organization_id: assister.organization.id,
          aid_application: {
              contact_method_confirmed: true
          }
      }
    end

    it 'updates the aid application with contact method confirmed' do
      aid_application = assigns(:aid_application)
      expect(aid_application).to be_persisted
      expect(aid_application).to have_attributes(
                                     creator: assister,
                                     organization: assister.organization
      )
      expect(aid_application.contact_method_confirmed).to eq true
    end

    it 'redirects to the dashboard page' do
      expect(response).to redirect_to organization_dashboard_path(assister.organization, aid_application)
    end
  end
end
