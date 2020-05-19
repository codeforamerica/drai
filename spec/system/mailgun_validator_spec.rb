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

    within_fieldset "Do you currently have a valid document that authorizes you to work in the United States?" do
      choose "No"
      expect(find_field("No", checked: true)).to be_present
    end

    check "Are you or have you experienced symptoms consistent with COVID-19?"

    click_on "Continue"

    within_fieldset "How would you like to receive the messages with your Application Number and Activation Code?" do
      check "Email"
      expect(find_field("Email", checked: true)).to be_present
    end

    allow(MailgunEmailValidator).to receive(:valid?).and_return(false)
    fill_in "Email address (if available)", with: "example@example.com"
    click_on 'Submit'

    expect(page).to have_content I18n.t("activerecord.errors.messages.mailgun_email_invalid")

    check I18n.t('aid_applications.applicants.edit.contact_information.confirmed_invalid_email')
    expect(find_field(I18n.t('aid_applications.applicants.edit.contact_information.confirmed_invalid_email'), checked: true)).to be_present

    click_on 'Submit'

    expect(page).not_to have_content I18n.t("activerecord.errors.messages.mailgun_email_invalid")


  end
end
