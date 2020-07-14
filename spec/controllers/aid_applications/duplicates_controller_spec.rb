require 'rails_helper'

describe AidApplications::DuplicatesController do
  describe '#update' do
    context 'duplication at submission' do
      let(:assister) { create :assister }
      let(:aid_application) { create :aid_application, creator: assister, organization: assister.organization }
      let(:duplicate_app) { create :aid_application, :submitted, creator: assister, organization: assister.organization, name: aid_application.name, street_address: aid_application.street_address, zip_code: aid_application.zip_code, birthday: aid_application.birthday }

      before do
        sign_in assister
      end

      it 'marks application as submitted' do
        put :update, params: {
          aid_application_id: aid_application.id,
          organization_id: assister.organization.id
        }

        aid_application.reload
        expect(aid_application.submitted_at).to be_within(1.second).of(Time.current)
        expect(aid_application.submitter).to eq assister
      end

      it 'redirects to the confirmation page' do
        put :update, params: {
          aid_application_id: aid_application.id,
          organization_id: assister.organization.id
        }

        expect(response).to redirect_to edit_organization_aid_application_confirmation_path(assister.organization, aid_application)
      end
    end

    context 'duplication at approval' do
      let(:supervisor) { create :supervisor }
      let(:aid_application) { create :aid_application, :submitted, creator: supervisor, organization: supervisor.organization }
      let(:duplicate_app) { create :aid_application, :approved, creator: supervisor, organization: supervisor.organization, name: aid_application.name, street_address: aid_application.street_address, zip_code: aid_application.zip_code, birthday: aid_application.birthday }

      before do
        sign_in supervisor
      end

      it 'marks application as approved' do
        put :update, params: {
          aid_application_id: aid_application.id,
          organization_id: supervisor.organization.id
        }

        aid_application.reload
        expect(aid_application.approved_at).to be_within(1.second).of(Time.current)
        expect(aid_application.approver).to eq supervisor
      end

      it 'redirects to the disbursements' do
        put :update, params: {
          aid_application_id: aid_application.id,
          organization_id: supervisor.organization.id
        }

        expect(response).to redirect_to edit_organization_aid_application_disbursement_path(supervisor.organization, aid_application)
      end
    end
  end
end
