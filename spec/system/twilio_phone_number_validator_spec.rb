require 'rails_helper'

describe 'Twilio Phone Number Validator', type: :system do
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

    within_fieldset "Do you currently have a valid document that authorizes you to work in the United States?" do
      choose "No"
      expect(find_field("No", checked: true)).to be_present
    end

    check "Are you or have you experienced symptoms consistent with COVID-19?"

    click_on "Continue"

    within_fieldset "How would you like to receive the messages with your Application Number and Activation Code?" do
      check "Text message"
      expect(find_field("Text message", checked: true)).to be_present
    end

    allow(TwilioPhoneNumberValidator).to receive(:valid?).and_return(false)
    fill_in "Phone number", with: "111-222-3333"
    click_on 'Submit'

    expect(page).to have_content I18n.t("activerecord.errors.messages.twilio_phone_number_invalid")

    check I18n.t('aid_applications.applicants.edit.contact_information.confirmed_invalid_phone_number')
    expect(find_field(I18n.t('aid_applications.applicants.edit.contact_information.confirmed_invalid_phone_number'), checked: true)).to be_present

    click_on 'Submit'

    expect(page).not_to have_content I18n.t("activerecord.errors.messages.twilio_phone_number_invalid")
  end
end
