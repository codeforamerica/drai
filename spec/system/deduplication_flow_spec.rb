require 'rails_helper'

RSpec.describe 'Deduplication flow', type: :system do
  context 'on application submission' do
    let!(:assister) { create :assister }
    let!(:aid_app) { create :aid_application, :submitted, creator: assister, organization: assister.organization }
    let!(:duplicate_app) { create :aid_application, creator: assister, organization: assister.organization, name: aid_app.name, street_address: aid_app.street_address, zip_code: aid_app.zip_code, birthday: aid_app.birthday }

    it 'shows the duplication page when submitting a duplicate app and allows deletion' do
      sign_in assister
      visit edit_organization_aid_application_applicant_path(organization_id: assister.organization.id, aid_application_id: duplicate_app.id)

      click_on 'Submit'
      expect(page).to have_content 'Potential duplicate identified'

      click_on 'Delete this application'
      expect(page).to have_content 'Start a new application'
      expect(AidApplication.find_by(id: duplicate_app.id)).to be_nil
    end

    it 'allows assister to submit duplicate app anyway' do
      sign_in assister
      visit edit_organization_aid_application_applicant_path(organization_id: assister.organization.id, aid_application_id: duplicate_app.id)

      click_on 'Submit'
      expect(page).to have_content 'Potential duplicate identified'

      click_on 'Submit anyway'

      expect(duplicate_app.reload.submitted_at).to be_present
      expect(page).to have_content 'Review and submit'
      expect(duplicate_app.ignored_duplicate_aid_applications).to contain_exactly(aid_app)
    end
  end

  context 'on application approval' do
    let!(:supervisor) { create :supervisor }
    let!(:assister) { create :assister, organization: supervisor.organization }
    let!(:approved_app) { create :aid_application, :approved, creator: assister, organization: supervisor.organization }
    let!(:duplicate_app) { create :aid_application, :submitted, creator: assister, organization: supervisor.organization, name: approved_app.name, street_address: approved_app.street_address, zip_code: approved_app.zip_code, birthday: approved_app.birthday }

    it 'shows the duplication page when approving a duplicate app and allows deletion' do
      sign_in supervisor
      visit root_path
      click_on duplicate_app.application_number
      click_on 'Determination'
      click_on 'Approve and continue to disbursement'

      expect(page).to have_content 'Potential duplicate identified'
      expect(duplicate_app.reload.approved_at).to be_nil

      click_on 'Delete this application'
      expect(page).to have_content 'Start a new application'
      expect(AidApplication.find_by(id: duplicate_app.id)).to be_nil
    end

    it 'allows supervisor to approve duplicate app anyway' do
      sign_in supervisor
      visit root_path
      click_on duplicate_app.application_number
      click_on 'Determination'
      click_on 'Approve and continue to disbursement'

      expect(page).to have_content 'Potential duplicate identified'
      click_on 'Approve anyway'

      expect(page).to have_content 'Disburse card'
      expect(duplicate_app.reload.approved_at).to be_present
      expect(duplicate_app.ignored_duplicate_aid_applications).to contain_exactly(approved_app)
    end
  end

  context 'when submitting and approving' do
    let!(:supervisor) { create :supervisor }
    let!(:aid_app) { create :aid_application, :submitted, creator: supervisor, organization: supervisor.organization }
    let!(:duplicate_app) { create :aid_application, creator: supervisor, organization: supervisor.organization, name: aid_app.name, street_address: aid_app.street_address, zip_code: aid_app.zip_code, birthday: aid_app.birthday }

    it 'allows assister to submit duplicate app anyway' do
      sign_in supervisor
      visit edit_organization_aid_application_applicant_path(organization_id: supervisor.organization.id, aid_application_id: duplicate_app.id)

      click_on 'Submit'
      expect(page).to have_content 'Potential duplicate identified'

      click_on 'Submit anyway'

      expect(duplicate_app.reload.submitted_at).to be_present
      expect(page).to have_content 'Review and submit'
      expect(duplicate_app.ignored_duplicate_aid_applications).to contain_exactly(aid_app)

      # Behind the scenes, someone else approves the duplicate app
      aid_app.save_and_approve(approver: supervisor)

      click_on 'Determination'
      click_on 'Approve and continue to disbursement'

      expect(page).to have_content 'Potential duplicate identified'
      click_on 'Approve anyway'

      expect(page).to have_content 'Disburse card'
    end
  end
end
