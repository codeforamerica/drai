require 'rails_helper'

describe 'Verify aid application', type: :system do
  let!(:organization) { create :organization }
  let!(:assister) { create :assister, organization: organization }
  let!(:supervisor) { create :supervisor, organization: organization }
  let!(:aid_application) { create :aid_application, :submitted, creator: assister }

  before { AidApplicationSearch.refresh }

  context 'when an assister is logged in' do
    context 'when the application is paused' do
      let!(:aid_application) { create :aid_application, :paused, creator: assister }

      it 'does not allow unpausing' do
        sign_in assister
        visit root_path

        within '.searchbar' do
          fill_in "q", with: aid_application.application_number
          click_on 'Search'
        end

        click_on aid_application.application_number

        within '#application-navigation' do
          click_on 'Verify'
        end

        expect(page).to have_content "Only supervisors can unpause applications."
      end
    end
  end

  context 'when a supervisor is logged in' do
    context 'when changes are made' do
      it 'redirects to the dashboard' do
        sign_in supervisor
        visit root_path

        within '.searchbar' do
          fill_in "q", with: aid_application.application_number
          click_on 'Search'
        end

        click_on aid_application.application_number

        within '#application-navigation' do
          click_on 'Verify'
        end

        fill_in "Full name", with: "New Name"
        fill_in "aid_application[birthday(1i)]", with: "2000"
        fill_in "aid_application[birthday(2i)]", with: "2"
        fill_in "aid_application[birthday(3i)]", with: "2"
        select "Bisexual", from: "Sexual orientation"
        select "Another gender identity", from: "Gender"

        within_fieldset "Which documents have been submitted?" do
          check "Photo ID"
          check "Proof of Address"
          check "COVID-19 Impact"
        end

        fill_in "Leave a note about verification (optional)", with: "Lotsa docs"

        click_on 'Save and exit'

        expect(page).to have_content 'Start a new application'

        aid_application = AidApplication.last
        expect(aid_application).to have_attributes(
                                     name: "New Name",
                                     birthday: "02-02-2000".to_date,
                                     sexual_orientation: "Bisexual",
                                     gender: "Another gender identity",
                                     verified_photo_id: true,
                                     verified_proof_of_address: true,
                                     verified_covid_impact: true,
                                     verification_case_note: "Lotsa docs"
                                   )
      end
    end

    context 'when the application is a duplicate of an approved application' do
      before do
        duplicate = aid_application.dup
        duplicate.update!(
          application_number: duplicate.generate_application_number,
          approved_at: 1.day.ago,
          approver: supervisor
        )
      end

      it 'shows the duplicate application screen' do
        sign_in supervisor
        visit root_path

        within '.searchbar' do
          fill_in "q", with: aid_application.application_number
          click_on 'Search'
        end

        click_on aid_application.application_number

        within '#application-navigation' do
          click_on 'Verify'
        end

        click_on 'Save and exit'

        expect(page).to have_content 'This applicant has been identified as a duplicate.'

        click_on "Go back"

        expect(current_path).to eq edit_organization_aid_application_verification_path(aid_application.organization, aid_application, locale: 'en')
      end
    end

    context 'when the application is paused' do
      let!(:aid_application) { create :aid_application, :paused, creator: assister }

      it 'allows unpausing' do
        sign_in supervisor
        visit root_path

        within '.searchbar' do
          fill_in "q", with: aid_application.application_number
          click_on 'Search'
        end

        click_on aid_application.application_number

        within '#application-navigation' do
          click_on 'Verify'
        end

        expect(page).to have_content "Restart application"

        click_on "Restart application"

        expect(page).not_to have_content "Restart application"

        expect(aid_application.reload).to have_attributes(
                                            paused_at: nil,
                                            unpaused_at: be_within(1.minute).of(Time.current),
                                            unpauser: supervisor
                                          )
      end
    end
  end
end
