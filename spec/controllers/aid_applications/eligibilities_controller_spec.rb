require 'rails_helper'

describe AidApplications::EligibilitiesController do
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
              valid_work_authorization: false,
              no_cbo_association: true,
              covid19_reduced_work_hours: true,
              county_name: "San Francisco"
          }
      }
    end

    it 'updates the aid application with the eligibilty fields' do
      aid_application = assigns(:aid_application)
      expect(aid_application).to be_persisted
      expect(aid_application).to have_attributes(
                                     creator: assister,
                                     organization: assister.organization
      )
      expect(aid_application.valid_work_authorization).to eq false
      expect(aid_application.covid19_reduced_work_hours).to eq true
      expect(aid_application.county_name).to eq "San Francisco"
    end

    it 'redirects to the applicant information page' do
      expect(response).to redirect_to edit_organization_aid_application_applicant_path(assister.organization, aid_application)
    end
  end
end
