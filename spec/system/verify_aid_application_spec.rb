require 'rails_helper'

RSpec.describe 'Verify an aid application', type: :system do
  let!(:assister) { create :assister }

  specify 'when there is a possible duplicate member' do
    sign_in assister

    visit root_path
    click_on assister.organization.name

    click_on "Applications"
    click_on "Add new application"

    within '.member-fields-0' do
      fill_in "Name", with: "Alice"
      fill_in "aid_application[members_attributes][0][birthday(1i)]", with: "1980"
      fill_in "aid_application[members_attributes][0][birthday(2i)]", with: "1"
      fill_in "aid_application[members_attributes][0][birthday(3i)]", with: "1"
    end

    fill_in "Street Address", with: "123 Main Street"
    fill_in "City", with: "Big City"
    fill_in "ZIP Code", with: "94103"

    fill_in "Phone Number", with: "555-555-5555"
    fill_in "Email Address", with: "client@example.com"

    click_on "Submit"

    expect(page).to have_content "Possible Duplicate"
  end
end