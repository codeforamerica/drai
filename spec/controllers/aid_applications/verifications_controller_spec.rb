require 'rails_helper'

describe AidApplications::VerificationsController, type: :controller do
  let!(:assister) { create :assister }
  before { sign_in assister}

  describe '#edit' do
    it 'loads page' do
      aid_application = create(:aid_application)
      get :edit, params: { organization_id: assister.organization.id, aid_application: aid_application }
      expect(page).to have_http_status :ok
    end

    context 'when client is not a duplicate'
    context 'when client may be a duplicate' do
      let!(:current_org) { create :organization }
      let!(:other_org) { create :organization }
      let!(:current_app) { create :aid_application, organization: current_org }
      let!(:other_app) { create :aid_application, organization: other_org }

      it 'displays the duplicates on the page' do
        get :edit, params: { organization_id: current_org.id, aid_application_id: current_app.id }
        expect(response.body).to have_content "Potential Duplicate"
      end

    end
  end
end
