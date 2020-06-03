require 'rails_helper'

describe Organizations::AidApplicationsController, type: :controller do
  describe '#show' do
    let(:assister) { create :assister }
    let(:supervisor) { create :supervisor, organization: assister.organization }
    let(:submitted_application) { create :aid_application, :submitted, creator: assister }
    let(:approved_application) { create :aid_application, :approved, creator: assister }
    let(:disbursed_application) { create :aid_application, :disbursed, creator: assister }

    context 'when an assister' do
      before { sign_in assister }
      it 'redirects to confirmation page' do
        get :show, params: { organization_id: assister.organization.id, id: approved_application.id }
        expect(response).to redirect_to edit_organization_aid_application_confirmation_path(submitted_application.organization, approved_application)
      end
    end

    context 'when a supervisor' do
      before { sign_in supervisor }

      context 'when application is submitted' do
        it 'redirects to approval page' do
          get :show, params: { organization_id: assister.organization.id, id: submitted_application.id }
          expect(response).to redirect_to edit_organization_aid_application_verification_path(submitted_application.organization, submitted_application)
        end
      end

      context 'when application is approved' do
        it 'redirects to disbursement page' do
          get :show, params: { organization_id: assister.organization.id, id: approved_application.id }
          expect(response).to redirect_to edit_organization_aid_application_disbursement_path(approved_application.organization, approved_application)
        end
      end

      context 'when application is disbursed' do
        it 'redirects to finished page' do
          get :show, params: { organization_id: assister.organization.id, id: disbursed_application.id }
          expect(response).to redirect_to edit_organization_aid_application_finished_path(disbursed_application.organization, disbursed_application)
        end
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
                                   creator: assister,
                                   organization: assister.organization
                                 )
      expect(response).to redirect_to edit_organization_aid_application_eligibility_path(assister.organization, aid_application)
    end
  end

  describe '#destroy' do
    let(:assister) { create :assister }
    let!(:aid_application) { create :aid_application, creator: assister }

    before { sign_in assister }

    it 'deletes the aid application' do
      expect do
        delete :destroy, params: {
          organization_id: aid_application.organization.id,
          id: aid_application.id
        }
      end.to change(AidApplication, :count).by(-1)

      expect { aid_application.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(response).to redirect_to organization_dashboard_path(aid_application.organization)
    end

    context 'when aid application is disbursed' do
      let!(:aid_application) { create :aid_application, :disbursed, creator: assister }

      it 'does not allow deletion' do
        expect do
          delete :destroy, params: {
            organization_id: aid_application.organization.id,
            id: aid_application.id
          }
        end.not_to change(AidApplication, :count)
      end
    end
  end
end
