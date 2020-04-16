require 'rails_helper'

describe 'Account invites', type: :system do
  let(:email_address) { 'manager@cbo.org' }
  let(:password) { 'qwerty' }

  it 'allows user to receive an invite and can confirm and set up account' do
    # An admin will import a bunch of CBO contact info
    user = User.new email: email_address
    user.skip_confirmation_notification!
    user.save

    user.send_confirmation_instructions

    # User receives an email
    open_email email_address
    current_email.click_link 'Set up your account'

    fill_in 'Password', with: password
    click_button 'Set up account'

    expect(page).to have_content "Update account"
  end
end
