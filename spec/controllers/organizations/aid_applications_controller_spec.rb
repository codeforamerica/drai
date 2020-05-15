require 'rails_helper'

describe Organizations::AidApplicationsController, type: :controller do
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
end
