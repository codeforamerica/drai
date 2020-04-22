require 'rails_helper'

describe 'Start aid application', type: :system do
  let!(:user) { create :user }

  specify do
    sign_in user

    visit root_path
    click_on user.organization.name

    click_on "Applications"
    click_on "Add new application"

    fill_in "Street Address", with: "123 Main Street"
    fill_in "City", with: "Big City"
    fill_in "ZIP Code", with: "94103"

    fill_in "Phone Number", with: "555-555-5555"
    fill_in "Email Address", with: "client@example.com"

    within '.member-fields-0' do
      fill_in "Name", with: "Client One"
      fill_in "aid_application[members_attributes][0][birthday(1i)]", with: "1980"
      fill_in "aid_application[members_attributes][0][birthday(2i)]", with: "1"
      fill_in "aid_application[members_attributes][0][birthday(3i)]", with: "1"
    end

    within '.member-fields-1' do
      fill_in "Name", with: "Client Two"
      fill_in "aid_application[members_attributes][1][birthday(1i)]", with: "1981"
      fill_in "aid_application[members_attributes][1][birthday(2i)]", with: "1"
      fill_in "aid_application[members_attributes][1][birthday(3i)]", with: "1"
    end

    click_on "Create aid application"

    aid_application = AidApplication.last
    expect(aid_application).to have_attributes(
                                 assister: user,
                                 organization: user.organization,
                                 street_address: "123 Main Street",
                                 city: "Big City",
                                 zip_code: "94103"
                               )

    members = aid_application.members
    expect(members.first).to have_attributes(
                               name: 'Client One',
                               birthday: '1/1/1980'.to_date
                             )
    expect(members.second).to have_attributes(
                               name: 'Client Two',
                               birthday: '1/1/1981'.to_date
                             )

    within "##{dom_id aid_application}" do
      expect(page).to have_content aid_application.id
      expect(page).to have_content user.name
    end
  end
end
