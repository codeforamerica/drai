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

    check I18n.t('general.confirm', locale: :es)

    within_fieldset I18n.t('aid_applications.eligibilities.edit.eligibility.label_text', locale: :es) do
      choose I18n.t('general.negative', locale: :es)
    end
    check I18n.t('aid_applications.eligibilities.edit.eligibility.reduced_work_hours', locale: :es)

    click_on I18n.t('general.continue', locale: :es)

    expect(page).to have_content "Información del solicitante"

    select 'Tagalo', from: 'new_locale'

    expect(page).to have_content "Impormasyon ng Aplikante"
  end
end
