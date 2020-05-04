require 'rails_helper'

describe 'Start aid application', type: :system do
  let!(:assister) { create :assister }

  specify do
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

    click_on 'Add a second person'

    within '.member-fields-1' do
      fill_in "Name", with: "Barbara"
      fill_in "aid_application[members_attributes][1][birthday(1i)]", with: "1981"
      fill_in "aid_application[members_attributes][1][birthday(2i)]", with: "1"
      fill_in "aid_application[members_attributes][1][birthday(3i)]", with: "1"
    end

    within '.member-fields-0' do
      click_on 'Remove Person'
    end

    expect(page).to have_content "California address"
    expect(page).to have_content "An address is required. Homeless clients can use a shelter or other address."
    fill_in "Street Address", with: "123 Main Street"
    fill_in "City", with: "Big City"
    fill_in "ZIP Code", with: "94103"

    fill_in "Phone Number", with: "555-555-5555"
    fill_in "Email Address", with: "client@example.com"

    click_on "Submit"

    aid_application = AidApplication.last
    expect(aid_application).to have_attributes(
                                 assister: assister,
                                 organization: assister.organization,
                                 street_address: "123 Main Street",
                                 city: "Big City",
                                 zip_code: "94103"
                               )
    expect(aid_application.members.size).to eq 1

    member = aid_application.members.first
    expect(member.name).to eq 'Barbara'
  end
end
