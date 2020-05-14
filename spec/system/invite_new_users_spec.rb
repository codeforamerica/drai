require 'rails_helper'

describe 'Account invitations', type: :system do
  let!(:organization) { create :organization }
  let(:admin) { create :admin }
  let(:supervisor) { create :supervisor, organization: organization }

  let(:new_user_email) { 'daffyduck@example.org' }
  let(:new_user_password) { 'Password!2' }

  # log in
  # view list of assisters
  # click on 'Add new user'
  # Enter email address to invite
  # Return to list of assisters
  # See that newly added user is on list with status
  it 'can be initiated by a Site Admin' do
    new_user = nil

    Capybara.using_session(:admin) do
      sign_in admin
      visit assisters_path

      click_on 'Add new assister'

      select organization.name, from: 'Organization'
      fill_in 'Name', with: 'Daffy Duck'
      fill_in 'Email', with: new_user_email
      click_on 'Invite assister'

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

  it 'can be initiated by a Supervisor' do
    sign_in supervisor
    visit root_path

    click_on 'Assisters'
    click_on 'Add new assister'

    fill_in 'Name', with: 'Daffy Duck'
    fill_in 'Email', with: new_user_email
    click_on 'Invite assister'

    expect(current_path).to eq organization_assisters_path(supervisor.organization)
    expect(page).to have_content "Sent invite to #{new_user_email}"

    new_user = User.last
    expect(new_user).to have_attributes(
      email: new_user_email,
      organization: supervisor.organization
    )
  end

  it 'assisters cannot see Assisters tab' do
    assister = create :assister

    sign_in assister
    visit root_path

    expect(page).not_to have_link 'Assisters'
  end
end
