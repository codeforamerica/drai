require 'rails_helper'

describe 'Approve aid application', type: :system do
  let!(:organization) { create :organization }
  let!(:assister) { create :assister, organization: organization }
  let!(:supervisor) { create :supervisor, organization: organization }
  let!(:aid_application) { create :aid_application, :submitted, creator: assister }
  let!(:payment_card) { create :payment_card }

  before do
    AidApplicationSearch.refresh
    allow(BlackhawkApi).to receive(:activate).and_return(true)
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
  end

  specify do
    sign_in supervisor
    visit root_path

    within '.searchbar' do
      fill_in "q", with: aid_application.application_number
      click_on 'Search'
    end

    click_on aid_application.application_number

    expect(page).to have_content "Verify"

    ## Ensure that mailing address is still validated after submission
    accept_alert do
      click_on "Remove mailing address"
    end
    click_on "Add a separate mailing address"

    within '.mailing-address' do
      fill_in "ZIP Code", with: "02130"
    end

    click_on 'Continue'

    # Expect validation errors
    within '.mailing-address' do
      fill_in "Street Address", with: "123 Rural Street"
      fill_in "Apartment, building, unit, etc. (optional)", with: "Unit A"
      fill_in "City", with: "Other Town"
      fill_in "State", with: "Massachusetts"
    end
    ## /Ensure that mailing address is still validated after submission

    within '#application-navigation' do
      click_on 'Determination'
    end

    expect(page).to have_content 'Approve and exit'
    perform_enqueued_jobs do
      click_on 'Approve and continue to disbursement'
    end

    open_sms aid_application.phone_number
    expect(current_sms).to have_content "Your application for Disaster Assistance has been approved"

    open_email aid_application.email
    expect(current_email).to have_content "Your application for Disaster Assistance has been approved"

    aid_application.reload
    expect(aid_application.approved_at).to be_within(2.seconds).of(Time.current)
    expect(aid_application.approver).to eq supervisor

    fill_in I18n.t('aid_applications.disbursements.edit.sequence_number'), with: "garbage", match: :first
    click_on I18n.t('aid_applications.disbursements.edit.disburse_card')

    expect(page).to have_content I18n.t('activerecord.errors.messages.sequence_number_invalid')
    expect(page).to have_content I18n.t('activerecord.errors.messages.sequence_numbers_must_match')

    fill_in I18n.t('aid_applications.disbursements.edit.sequence_number'), with: payment_card.sequence_number
    fill_in I18n.t('aid_applications.disbursements.edit.sequence_number_confirmation'), with: payment_card.sequence_number
    click_on I18n.t('aid_applications.disbursements.edit.disburse_card')

    expect(page).to have_content "Card successfully disbursed"

    accept_alert do
      click_on "Emergency access"
    end

    payment_card.reload
    expect(page).to have_content payment_card.activation_code

    expect(payment_card.activation_code).to be_present
    expect(payment_card.aid_application_id).to eq aid_application.id

    aid_application.reload
    expect(aid_application.disbursed_at).to be_within(1.second).of Time.current
    expect(aid_application.disburser).to eq(supervisor)

    expect(BlackhawkApi).to have_received(:activate).with(
      quote_number: payment_card.quote_number,
      proxy_number: payment_card.proxy_number,
      activation_code: payment_card.activation_code
    )
    expect(payment_card.blackhawk_activation_code_assigned_at).to be_within(1.second).of Time.current

    open_sms aid_application.phone_number
    expect(current_sms).to have_content payment_card.activation_code

    open_email aid_application.email
    expect(current_email).to have_content payment_card.activation_code

    reveal_activation_code_log = RevealActivationCodeLog.last
    expect(reveal_activation_code_log).to be_present
    expect(reveal_activation_code_log).to have_attributes(
                                            aid_application: aid_application,
                                            user: supervisor
                                          )
  end
end
