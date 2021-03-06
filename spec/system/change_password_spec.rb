require 'rails_helper'

describe 'Password reset', type: :system do
  let!(:user) { create :user }

  it 'allows a user to reset their password' do
    visit root_path

    within 'form' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'Password!2'
      click_on 'Sign in'
    end

    click_on 'Account'
    click_on 'Change password'

    fill_in 'Current password', with: 'Password!2'
    fill_in 'New password', with: 'Qwerty!2'
    fill_in 'Confirm new password', with: 'Qwerty!2'
    click_on 'Update'

    expect(page).to have_content 'Your account has been updated.'

    click_on 'Sign out', match: :first

    within 'form' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'Qwerty!2'
      click_on 'Sign in'
    end

    expect(page).to have_link 'Account'
  end

  it 'allows a user to reset their password' do
    visit root_path
    click_on 'Forgot your password?'

    fill_in 'Email', with: user.email
    perform_enqueued_jobs do
      click_on 'Send me an email'
    end
    open_email user.email
    current_email.click_link 'Change my password'

    fill_in 'New password', with: 'Abcdefg!2'
    click_on 'Change my password'

    expect(page).to have_content 'Your password has been changed successfully. You are now signed in.'
  end
end
