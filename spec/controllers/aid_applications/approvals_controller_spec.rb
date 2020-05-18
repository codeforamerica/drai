require 'rails_helper'

describe AidApplications::ApprovalsController do
  let(:supervisor) { create :supervisor }
  let(:aid_application) { create :aid_application, :submitted, organization: supervisor.organization }

  before do
    sign_in supervisor
  end

  describe '#update' do
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
