require 'rails_helper'

describe 'Start aid application', type: :system do
  let!(:assister) { create :assister }

  specify do
    sign_in assister

    visit root_path
    click_on assister.organization.name

    click_on "Applications"
    click_on "Add new application"


    expect(page).to have_content "Applicant Information"
    within '.member-fields-0' do
      fill_in "Full name", with: "Alice"
      fill_in "aid_application[members_attributes][0][birthday(1i)]", with: "1980"
      fill_in "aid_application[members_attributes][0][birthday(2i)]", with: "1"
      fill_in "aid_application[members_attributes][0][birthday(3i)]", with: "1"
    end

    click_on 'Add a second person'

    within '.member-fields-1' do
      fill_in "Full name", with: "Barbara"
      fill_in "aid_application[members_attributes][1][birthday(1i)]", with: "1981"
      fill_in "aid_application[members_attributes][1][birthday(2i)]", with: "1"
      fill_in "aid_application[members_attributes][1][birthday(3i)]", with: "1"

      expect(page).to have_content "The following questions are optional for the client to answer. If left blank, they will be recorded as \"prefer not to answer\"."
      fill_in "Preferred language (optional)", with: "Spanish"
      fill_in "Country of origin", with: "Canada"
      fill_in "Racial/ethnic identity", with: "Martian"
      fill_in "Sexual orientation", with: "Qweer"
      fill_in "Gender", with: ''
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

    click_on 'Submit'

    expect(page).to have_content 'Application submitted'
    expect(page).to have_content /APP-/

    aid_application = AidApplication.last
    expect(aid_application).to have_attributes(
                                 creator: assister,
                                 organization: assister.organization,
                                 street_address: "123 Main Street",
                                 city: "Big City",
                                 zip_code: "94103"
                               )
    expect(aid_application.members.size).to eq 1

    member = aid_application.members.first
    expect(member).to have_attributes(
                          name: "Barbara",
                          preferred_language: "Spanish",
                          country_of_origin: 'Canada',
                          racial_ethnic_identity: 'Martian',
                          sexual_orientation: "Qweer",
                          gender: nil
                      )
  end
end
