require 'rails_helper'

describe 'Approve aid application', type: :system do
  let!(:organization) { create :organization, total_payment_cards_count: 2 }
  let!(:assister) { create :assister, organization: organization }
  let!(:supervisor) { create :supervisor, organization: organization }
  let!(:aid_applications) { create_list :aid_application, 2, :submitted, creator: assister }
  let!(:waitlisted_application) { create :aid_application, :submitted, creator: assister }

  before do
    AidApplicationWaitlist.refresh(concurrently: false)
  end

  it 'shows waitlisted behaviors' do
    sign_in supervisor
    visit root_path

    expect(page).to have_content "Any new applications will be put on a waitlist."
    expect(page).to have_content "Waitlist #1"

    select 'Waitlisted', from: 'Filter'
    click_on waitlisted_application.application_number

    click_on 'Eligibility'
    expect(page).to have_content "Explain to the client that they are on a waitlist"

    click_on 'Determination'
    expect(page).to have_button('Approve and exit', disabled: true)
    expect(page).to have_button('Approve and continue to disbursement', disabled: true)

    # Reject one of the other applications
    visit root_path
    click_on aid_applications.first.application_number
    click_on 'Determination'
    accept_alert do
      click_on 'Reject application'
    end

    AidApplicationWaitlist.refresh(concurrently: false)

    # Verify that the previous waitlisted application is not on the waitlist
    visit root_path
    click_on waitlisted_application.application_number
    expect(page).not_to have_content "Waitlist #1"
    click_on 'Determination'
    expect(page).to have_button('Approve and exit', disabled: false)
  end
end
