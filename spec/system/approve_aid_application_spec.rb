require 'rails_helper'

describe 'Approve aid application', type: :system do
  let!(:organization) { create :organization }
  let!(:assister) { create :assister, organization: organization }
  let!(:supervisor) { create :supervisor, organization: organization }
  let!(:aid_application) { create :aid_application, :submitted, creator: assister }

  before do
    AidApplicationSearch.refresh
  end

  specify do
    sign_in supervisor
    visit root_path
    click_on assister.organization.name
    click_on 'Applications'

    within '.searchbar' do
      fill_in "term", with: aid_application.name
      click_on 'search_submit'
    end

    click_on "Update-Verify-Disburse"

    within '#application-navigation' do
      click_on 'Approve'
    end

    click_on 'Approve'

    aid_application.reload
    expect(aid_application.approved_at).to be_within(1.second).of(Time.current)
    expect(aid_application.approver).to eq supervisor
  end
end
