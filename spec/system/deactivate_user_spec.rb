require 'rails_helper'

describe 'Deactivate Users', type: :system do
  let!(:organization) { create :organization }
  let!(:supervisor) { create :supervisor, organization: organization }
  let!(:assister) { create :assister, organization: organization }
  let!(:aid_application) { create :aid_application, :submitted, creator: assister, organization: organization }

  it 'can be initiated by a Site Admin' do
    # Sign as the assister (just to have an active session)
    Capybara.using_session(:assister) do
      sign_in assister
      visit root_path
      expect(page).to have_link 'Sign out'
    end

    Capybara.using_session(:supervisor) do
      sign_in supervisor
      visit root_path

      click_on 'Assisters'

      # Supervisor cannot deactivate themselves
      within "##{dom_id(supervisor)}" do
        expect(page).not_to have_content 'Deactivate'
      end

      # Deactivate the Assister
      within "##{dom_id(assister)}" do
        accept_confirm do
          click_on 'Deactivate'
        end
      end

      expect(page).to have_content 'Deactivated Assisters'
      within "#deactivated-assisters ##{dom_id(assister)}" do
        expect(page).to have_content assister.name
        expect(page).to have_content 'Deactivated'
        click_on "Edit"
      end
      expect(page).to have_content "#{supervisor.name} deactivated account"
      click_on 'Cancel'

      # Ensure that an application still shows the assister
      click_on 'Applications'
      within "##{dom_id(aid_application)}" do
        expect(page).to have_content assister.name
      end
    end

    # Go back to Assister's session
    # Expect any action they take to sign them out
    # They cannot log in again
    Capybara.using_session(:assister) do
      visit root_path
      expect(page).not_to have_link 'Sign out'

      within 'form' do
        fill_in 'Email', with: assister.email
        fill_in 'Password', with: 'Password!2'
        click_on 'Sign in'
      end

      expect(page).to have_content 'Account has been deactivated'
    end
  end
end
