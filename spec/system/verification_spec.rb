require 'rails_helper'

describe 'Verify aid application', type: :system do
  let!(:organization) { create :organization }
  let!(:assister) { create :assister, organization: organization }
  let!(:supervisor) { create :supervisor, organization: organization }
  let!(:aid_application) { create :aid_application, :submitted, creator: assister }

  before { AidApplicationSearch.refresh }

  context 'when a supervisor is logged in' do
    context 'when changes are made' do
      it 'redirects to the dashboard' do
        sign_in supervisor
        visit root_path

        within '.searchbar' do
          fill_in "q", with: aid_application.application_number
          click_on 'Search'
        end

        click_on aid_application.application_number

        within '#application-navigation' do
          click_on 'Verify'
        end

        fill_in "Full name", with: "New Name"
        fill_in "aid_application[birthday(1i)]", with: "2000"
        fill_in "aid_application[birthday(2i)]", with: "2"
        fill_in "aid_application[birthday(3i)]", with: "2"
        select "Bisexual", from: "Sexual orientation"
        select "Another gender identity", from: "Gender"

        click_on 'Save and exit'

        expect(page).to have_content 'Start a new application'

        aid_application = AidApplication.last
        expect(aid_application).to have_attributes(
                                       name: "New Name",
                                       birthday: "02-02-2000".to_date,
                                       sexual_orientation: "Bisexual",
                                       gender: "Another gender identity",
                                       )

      end
    end
  end
end
