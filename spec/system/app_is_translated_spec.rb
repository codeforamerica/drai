require 'rails_helper'

describe 'Start aid application and translate text', type: :system, js: true do
  let!(:assister) { create :assister, organization: build(:organization, county_names: ["San Francisco", "San Mateo"]) }

  specify do
    sign_in assister

    visit root_path

    click_on "Start a new application"

    expect(page).to have_content "About the DRAI program"

    select 'Spanish', from: 'new_locale'

    expect(page).to have_content "Acerca del programa DRAI"

    click_on 'Dashboard'
    click_on "Start a new application"

    expect(page).to have_content "Acerca del programa DRAI"
  end
end
