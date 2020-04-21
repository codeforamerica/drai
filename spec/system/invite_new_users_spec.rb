require 'rails_helper'

describe 'Users can invite new accounts when logged in', type: :system do
  let!(:user) { create :user }
  let!(:new_user_email) { 'daffyduck@dafi.org' }
  let!(:new_user_password) { 'password1' }

  specify do
    new_user = nil

    Capybara.using_session(:admin) do
      sign_in user
      visit assisters_path
      expect(page).to have_content user.email

      click_on 'Add new user'
      fill_in 'Name', with: 'Daffy Duck'
      fill_in 'Email', with: new_user_email
      click_on 'Invite user'

      expect(current_path).to eq assisters_path
      expect(page).to have_content "Sent invite to #{new_user_email}"

      new_user = User.last
      expect(new_user.email).to eq new_user_email

      within("##{dom_id(new_user)}") do
        expect(page).to have_content new_user_email
        expect(page).to have_content 'Invited'
      end
    end

    Capybara.using_session(:new_user) do
      open_email new_user_email
      current_email.click_link 'Set up your account'
    end

    Capybara.using_session(:admin) do
      # reload the page and ensure that the status has changed
      visit current_path

      within("##{dom_id(new_user)}") do
        expect(page).to have_content new_user_email
        expect(page).to have_content 'Confirmed'
      end
    end

    Capybara.using_session(:new_user) do
      fill_in 'Choose a password', with: new_user_password
      click_button 'Set up account'

      within("##{dom_id(new_user)}") do
        expect(page).to have_content new_user_email
        expect(page).to have_content 'Active'
      end
    end
  end
  # log in
  # view list of assisters
  # click on 'Add new user'
  # Enter email address to invite
  # Return to list of assisters
  # See that newly added user is on list with status
end
