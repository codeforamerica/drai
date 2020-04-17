require 'rails_helper'

describe 'Users can invite new accounts when logged in', type: :system do
  let!(:user) { create :user }
  let!(:new_user_email) { 'daffyduck@dafi.org' }

  specify do
    sign_in user
    visit assisters_path
    expect(page).to have_content user.email

    click_on 'Add new user'
    fill_in 'Name', with: 'Daffy Duck'
    fill_in 'Email', with: new_user_email
    click_on 'Invite user'

    click_on 'Assisters'
    expect(page).to have_content new_user_email
    expect(page).to have_content 'Invited'
  end
  # log in
  # view list of assisters
  # click on 'Add new user'
  # Enter email address to invite
  # Return to list of assisters
  # See that newly added user is on list with status
end