require 'rails_helper'

describe 'Password reset', type: :system do
  let!(:user) { create :user }

  it 'allows a user to reset their password' do
    visit root_path
    click_on 'Sign in'
    click_on 'Forgot your password?'

    fill_in 'Email', with: user.email
    click_on 'Send me an email'

    open_email user.email
    current_email.click_link 'Change my password'

    fill_in 'New password', with: 'abcdefg'
    click_on 'Change my password'

    expect(page).to have_content 'Your password has been changed successfully. You are now signed in.'
  end
end
