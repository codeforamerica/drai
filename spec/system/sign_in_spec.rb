require 'rails_helper'

describe 'Home page redirects to the signin page' do
  context 'assister' do
    let!(:assister) { create(:assister, email: 'assister@foodbank.org', password: 'Qwerty!2', admin: false, supervisor: false) }

    it 'after sign in redirects to the aid applicants page for their organization' do
      visit root_path
      expect(page).to have_content "Sign in"
      expect(page).to have_content "Disaster Assistance For Immigrants"

      fill_in 'Email Address', with: 'assister@foodbank.org'
      fill_in 'Password', with: 'Qwerty!2'
      click_button 'Sign in'

      expect(page).to have_content "Start a new application"
    end
  end

  context 'supervisor' do
    let!(:supervisor) { create(:supervisor, email: 'supervisor@foodbank.org', password: 'Qwerty!2', admin: false, supervisor: true) }

    it 'after sign in redirects to their organization page' do
      visit root_path
      expect(page).to have_content "Sign in"
      expect(page).to have_content "Disaster Assistance For Immigrants"

      fill_in 'Email Address', with: 'supervisor@foodbank.org'
      fill_in 'Password', with: 'Qwerty!2'
      click_button 'Sign in'

      expect(page).to have_content "Start a new application"
    end
  end

  context 'user visits sign in url directly' do
    let!(:supervisor) { create(:supervisor, email: 'supervisor@foodbank.org', password: 'Qwerty!2', admin: false, supervisor: true) }

    it 'redirects to their organization page after sign in' do
      visit new_user_session_path

      expect(page).to have_content "Sign in"
      expect(page).to have_content "Disaster Assistance For Immigrants"

      fill_in 'Email Address', with: 'supervisor@foodbank.org'
      fill_in 'Password', with: 'Qwerty!2'
      click_button 'Sign in'

      expect(page).to have_content "Start a new application"
    end
  end
end
