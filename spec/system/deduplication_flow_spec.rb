require 'rails_helper'

RSpec.describe 'Deduplication flow', type: :system do
  context 'on application submission' do
    let!(:assister) { create :assister }
    let!(:aid_app) { create :aid_application, :submitted, creator: assister, organization: assister.organization }
    let!(:duplicate_app) { create :aid_application, creator: assister, organization: assister.organization, name: aid_app.name, street_address: aid_app.street_address, zip_code: aid_app.zip_code, birthday: aid_app.birthday }

    it 'shows the duplication page when submitting a duplicate app' do
      sign_in assister
      visit edit_organization_aid_application_applicant_path(organization_id: assister.organization.id, aid_application_id: duplicate_app.id)

      click_on 'Submit'
      expect(page).to have_content 'This applicant has been identified as a duplicate.'

      expect(duplicate_app.reload.submitted_at).to be_nil

      click_on 'Go back'
      expect(page).to have_content 'Applicant Information'

      click_on 'Submit'
      expect(page).to have_content 'This applicant has been identified as a duplicate.'

      click_on 'Delete this application'
      expect(page).to have_content 'Start a new application'
      expect(AidApplication.find_by(id: duplicate_app.id)).to be_nil
    end
  end
end