require 'rails_helper'

RSpec.describe 'CBO dashboard', type: :system do
  let!(:assister) { create :assister }
  let!(:aid_application) { create :aid_application, :submitted, organization: assister.organization }
  let!(:other_aid_application) { create :aid_application, :submitted, organization: assister.organization }

  before { AidApplicationSearch.refresh }

  it 'assisters can search for applications' do
    sign_in assister
    visit root_path

    within '.searchbar' do
      fill_in "q", with: aid_application.name
      click_on "Search"
    end

    expect(page).to have_content aid_application.application_number.to_s
    expect(page).not_to have_content other_aid_application.application_number.to_s
  end

  it 'assisters can filter applications by status', js: true do
    approved_application = create :aid_application, :approved, organization: assister.organization

    sign_in assister
    visit root_path

    select 'Approved', from: 'Filter'

    expect(page).to have_content approved_application.application_number
    expect(page).not_to have_content aid_application.application_number
    expect(page).not_to have_content other_aid_application.application_number
  end

  it 'shows the proper number of applications' do
    assister.organization.update(total_payment_cards_count: 10)
    create :aid_application, :partially_verified, organization: assister.organization
    create :aid_application, :verified, organization: assister.organization
    create :aid_application, :approved, organization: assister.organization
    create :aid_application, :disbursed, organization: assister.organization
    create :aid_application, :rejected, organization: assister.organization

    sign_in assister
    visit root_path

    save_and_open_page

    within '.statistics-uncommitted' do
      expect(page).to have_content '4' # remaining
      expect(page).to have_content '10' # total
    end

    within '.statistics-committed' do
      expect(page).to have_content '5'
    end

    within '.statistics-approved' do
      expect(page).to have_content '1'
    end

    within '.statistics-disbursed' do
      expect(page).to have_content '1'
    end
  end

  context 'when there are a high number of available cards' do
    it 'does not show a warning' do
      assister.organization.update(total_payment_cards_count: 6_000)

      sign_in assister
      visit root_path

      expect(page).not_to have_content "You are running low on remaining cards"
    end
  end

  context 'when there are a low number of available cards' do
    it 'shows a warning' do
      assister.organization.update(total_payment_cards_count: 100)

      sign_in assister
      visit root_path

      expect(page).to have_content "You are running low on remaining cards"
    end
  end

  context 'when there are 0 remaining available cards' do
    it 'shows a notice' do
      assister.organization.aid_applications.destroy_all

      create_list :aid_application, 2, :disbursed, organization: assister.organization
      assister.organization.update(total_payment_cards_count: 2)

      sign_in assister
      visit root_path

      within '.statistics-uncommitted' do
        expect(page).to have_content '0' # remaining
        expect(page).to have_content '2' # total
      end

      expect(page).to have_content "You have zero remaining cards."
    end
  end
end
