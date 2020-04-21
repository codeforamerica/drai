require 'rails_helper'

describe 'Start aid application', type: :system do
  let!(:user) { create :user }

  specify do
    sign_in user

    visit root_path
    click_on user.organization.name

    click_on "Applications"
    click_on "Add new application"
    click_on "Create aid application"

    aid_application = AidApplication.last
    expect(aid_application).to have_attributes(
                                 assister: user,
                                 organization: user.organization
                               )

    # TODO: have an application to fill out

    within "##{dom_id aid_application}" do
      expect(page).to have_content aid_application.id
      expect(page).to have_content user.name
    end
  end
end
