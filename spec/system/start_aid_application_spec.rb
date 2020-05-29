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
    expect(find_field("Confirm")).to be_checked

    expect(page).to have_content "Eligibility"

    within_fieldset "Do you currently have a valid document that authorizes you to work in the United States?" do
      choose "No"
      expect(find_field("No", checked: true)).to be_present
    end

    expect(page).to have_content I18n.t('aid_applications.eligibilities.edit.eligibility.read_to_client')
    check "Are you or have you experienced symptoms consistent with COVID-19?"

    click_on "Continue"

    expect(page).to have_content "Applicant Information"

    fill_in "Full name", with: "Alice"
    fill_in "aid_application[birthday(1i)]", with: "1980"
    fill_in "aid_application[birthday(2i)]", with: "1"
    fill_in "aid_application[birthday(3i)]", with: "1"

    expect(page).to have_content I18n.t('aid_applications.applicants.edit.contact_information.optional_questions_prompt')
    select "Spanish", from: I18n.t('aid_applications.applicants.edit.applicant_information.preferred_language')
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

    accept_alert do
      click_on "Remove mailing address"
    end
    expect(page).not_to have_content "Mailing address"

    click_on "Add a separate mailing address"

    within '.mailing-address' do
      fill_in "Street Address", with: "123 Rural Street"
      fill_in "Apartment, building, unit, etc. (optional)", with: "Unit A"
      fill_in "City", with: "Other Town"
      fill_in "State", with: "Massachusetts"
      fill_in "ZIP Code", with: "02130"
    end

    expect(page).to have_content "Contact information"

    fill_in "Phone number", with: "555-555-5555"
    fill_in "Email address (if available)", with: "example@example.com"

    within_fieldset "How would you like to receive the messages with your Application Number and Activation Code?" do
      check "Text message"
      expect(find_field("Text message", checked: true)).to be_present

      check "Email"
      expect(find_field("Email", checked: true)).to be_present
    end

    within '#preferred-contact-channel__text' do
      expect(page).to have_content 'Message and data rates may apply'
    end

    within_fieldset "Is anyone in your household currently receiving CalFresh or CalWORKs benefits?" do
      choose "Yes"
      expect(find_field("Yes", checked: true)).to be_present
    end

    within_fieldset "What unmet needs do you have?" do
      check "Childcare"
      check "Utilities"

      expect(find_field("Childcare", checked: true)).to be_present
      expect(find_field("Utilities", checked: true)).to be_present
    end

    within_fieldset "Applicant attestation" do
      check "Yes"
      expect(find_field("Yes", checked: true)).to be_present
    end

    perform_enqueued_jobs do
      click_on 'Submit'
    end

    expect(page).to have_content I18n.t('aid_applications.confirmations.edit.title')
    expect(page).to have_content /APP-/

    aid_application = AidApplication.last

    # Expect to receive SMS
    open_sms aid_application.phone_number
    expect(current_sms).to have_content aid_application.application_number

    # Expect to receive Email
    open_email aid_application.email
    expect(current_email).to have_content aid_application.application_number

    # Update Contact Information as if they did not receive the messages
    fill_in 'Email', with: ''
    click_on 'Update and re-send'

    expect(page).to have_content "can't be blank"

    fill_in 'Email', with: "test@example.com"
    perform_enqueued_jobs do
      click_on 'Update and re-send'
    end

    open_email "test@example.com"
    expect(current_email).to have_content aid_application.application_number

    # Read Verification Documents Section and Confirm Contact Information
    expect(page).to have_content 'Verification documents'
    expect(page).to have_content 'Next Steps'

    check "Contact method confirmed"
    expect(find_field("Contact method confirmed", checked: true)).to be_present

    within_fieldset "How will the applicant get their card?" do
      choose "Mail"
      expect(find_field("Mail", checked: true)).to be_present
    end

    click_on 'Submit'

    expect(page).to have_content 'Start a new application'

    aid_application.reload
    expect(aid_application).to have_attributes(
                                 creator: assister,
                                 organization: assister.organization,
                                 street_address: "123 Main Street",
                                 apartment_number: "Apt. 1",
                                 city: "Big City",
                                 zip_code: "94103",
                                 allow_mailing_address: true,
                                 mailing_street_address: "123 Rural Street",
                                 mailing_apartment_number: "Unit A",
                                 mailing_city: "Other Town",
                                 mailing_zip_code: "02130",
                                 mailing_state: "Massachusetts",
                                 phone_number: "5555555555",
                                 email: "test@example.com",
                                 sms_consent: true,
                                 email_consent: true,
                                 receives_calfresh_or_calworks: true,
                                 unmet_childcare: true,
                                 unmet_utilities: true,
                                 valid_work_authorization: false,
                                 covid19_experiencing_symptoms: true,
                                 name: "Alice",
                                 preferred_language: "Spanish",
                                 country_of_origin: 'Decline to state',
                                 racial_ethnic_identity: ['Asian Indian', 'Hispanic or Latino (any other race)'],
                                 sexual_orientation: "Bisexual",
                                 gender: "Another gender identity",
                                 birthday: "01-01-1980".to_date,
                                 attestation: true,
                                 contact_method_confirmed: true,
                               )
  end
end
