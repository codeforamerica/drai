require 'rails_helper'

describe AidApplications::DisbursementsController do
  let!(:aid_application) { create :aid_application, :approved }

  before do
    sign_in aid_application.approver
  end

  render_views

  it 'renders' do
    get :edit, params: {
      organization_id: aid_application.organization.id,
      aid_application_id: aid_application.id
    }

    expect(response).to have_http_status :ok
  end

  context 'when the card has been disbursed' do
    let!(:aid_application) { create :aid_application, :disbursed }

    it 'redirects to the activation instructions path' do
      get :edit, params: {
        organization_id: aid_application.organization.id,
        aid_application_id: aid_application.id
      }

      expect(response).to redirect_to edit_organization_aid_application_finished_path(aid_application.organization, aid_application)
    end
  end
end
