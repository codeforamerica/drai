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
      fill_in "term", with: aid_application.application_number
      click_on 'search_submit'
    end

    click_on aid_application.application_number

    within '#application-navigation' do
      click_on 'Approve'
    end

    click_on 'Approve'

    aid_application.reload
    expect(aid_application.approved_at).to be_within(1.second).of(Time.current)
    expect(aid_application.approver).to eq supervisor

    fill_in I18n.t('aid_applications.disbursements.edit.sequence_number'), with: "garbage"
    click_on I18n.t('aid_applications.disbursements.edit.disburse_card')

    expect(page).to have_content I18n.t('activerecord.errors.messages.sequence_number_invalid')

    fill_in I18n.t('aid_applications.disbursements.edit.sequence_number'), with: payment_card.sequence_number
    click_on I18n.t('aid_applications.disbursements.edit.disburse_card')

    expect(page).to have_content I18n.t('aid_applications.finisheds.edit.title')

    payment_card.reload

    expect(payment_card.aid_application_id).to eq aid_application.id
    expect(payment_card.activation_code).to be_present

    aid_application.reload
    expect(aid_application.disbursed_at).to be_within(1.second).of Time.current
    expect(aid_application.disburser).to eq(supervisor)

    expect(BlackhawkApi).to have_received(:activate).with(
      quote_number: payment_card.quote_number,
      proxy_number: payment_card.proxy_number,
      activation_code: payment_card.activation_code
    )
    expect(payment_card.activation_code_assigned_at).to be_within(1.second).of Time.current
  end
end
