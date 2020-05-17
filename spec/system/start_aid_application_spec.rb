require 'rails_helper'

describe 'Start aid application', type: :system do
  let!(:assister) { create :assister, organization: build(:organization, county_names: ["San Francisco", "San Mateo"]) }

  specify do
    sign_in assister

    visit root_path

    click_on "Start a new application"

    expect(page).to have_content "DRAI application"
    expect(page).to have_content "About the DRAI program"
    expect(page).to have_content "Privacy script"

    expect(page).to have_content "Service criteria"
    select "San Francisco", from: "County"

    check "Confirm"

    expect(page).to have_content "Eligibility"

    within_fieldset "Do you currently have a valid document that authorizes you to work in the United States?" do
      choose "No"
    end

    expect(page).to have_content I18n.t('aid_applications.eligibilities.edit.eligibility.read_to_client')
    check "Are you or have you experienced symptoms consistent with COVID-19?"

    click_on "Continue"

    expect(page).to have_content "Applicant Information"

    fill_in "Full name", with: "Alice"
    fill_in "aid_application[birthday(1i)]", with: "1980"
    fill_in "aid_application[birthday(2i)]", with: "1"
    fill_in "aid_application[birthday(3i)]", with: "1"

    expect(page).to have_content "The following questions are optional for the client to answer. If left blank, they will be recorded as 'prefer not to answer'."
    select "Spanish", from: "Language in which service is being provided to applicant"
    check "Asian Indian"
    select "Bisexual", from: "Sexual orientation"
    select "Another gender identity", from: "Gender"
    check "Hispanic or Latino (any other race)"

    expect(page).to have_content "An address is required. Homeless clients can use a shelter or other address."
    fill_in "Street Address", with: "123 Main Street"
    fill_in "Apartment, building, unit, etc. (optional)", with: "Apt. 1"
    fill_in "City", with: "Big City"
    fill_in "ZIP Code", with: "94103"

    click_on "Add a separate mailing address"

    expect(page).to have_content "Mailing address"
    within '.mailing-address' do
      fill_in "Street Address", with: "123 Rural Street"
      fill_in "Apartment, building, unit, etc. (optional)", with: "Unit A"
      fill_in "City", with: "Other Town"
      fill_in "State", with: "Massachusetts"
      fill_in "ZIP Code", with: "02130"
    end

    click_on "Remove mailing address"
    expect(page).not_to have_content "Mailing address"

    expect(page).to have_content "Contact information"

    fill_in "Phone number", with: "555-555-5555"
    fill_in "Email address (if available)", with: "example@example.com"

    within_fieldset "How would you like to recieve the messages with your Application Number and Activation Code?" do
      check "Text message"
    end

    within '#preferred-contact-channel__text' do
      expect(page).to have_content 'Message and data rates may apply'
    end

    within_fieldset "Is anyone in your household currently receiving CalFresh or CalWORKs benefits?" do
      choose "Yes"
    end

    within_fieldset "What unmet needs do you have?" do
      check "Childcare"
      check "Utilities"
    end

    within_fieldset "Applicant attestation" do
      check "Yes"
    end

    perform_enqueued_jobs do
      click_on 'Submit'
    end

    expect(page).to have_content 'Application submitted'
    expect(page).to have_content /APP-/

    check "Contact method confirmed"

    expect(page).to have_content 'Verification documents'
    expect(page).to have_content 'Next Steps'

    within_fieldset "How will the applicant get their card?" do
      choose "Mail"
    end

    click_on 'Submit'

    expect(page).to have_content 'Start a new application'

    aid_application = AidApplication.last
    expect(aid_application).to have_attributes(
                                 creator: assister,
                                 organization: assister.organization,
                                 street_address: "123 Main Street",
                                 apartment_number: "Apt. 1",
                                 city: "Big City",
                                 zip_code: "94103",
                                 allow_mailing_address: false,
                                 mailing_street_address: nil,
                                 mailing_apartment_number: nil,
                                 mailing_city: nil,
                                 mailing_zip_code: nil,
                                 mailing_state: nil,
                                 phone_number: "5555555555",
                                 email: "example@example.com",
                                 sms_consent: true,
                                 email_consent: false,
                                 receives_calfresh_or_calworks: true,
                                 unmet_childcare: true,
                                 unmet_utilities: true,
                                 valid_work_authorization: false,
                                 covid19_experiencing_symptoms: true,
                                 name: "Alice",
                                 preferred_language: "Spanish",
                                 country_of_origin: 'Prefer not to answer',
                                 racial_ethnic_identity: ['Asian Indian', 'Hispanic or Latino (any other race)'],
                                 sexual_orientation: "Bisexual",
                                 gender: "Another gender identity",
                                 birthday: "01-01-1980".to_date,
                                 attestation: true,
                                 contact_method_confirmed: true,
                               )

    open_sms aid_application.phone_number
    expect(current_sms).to have_content aid_application.application_number
  end
end
