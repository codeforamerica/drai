require 'rails_helper'

describe 'Session timeout' do
  let(:assister) { create :assister }

  it 'logs person out after 20 minutes of inactivity' do
    sign_in assister
    visit root_path

    Timecop.travel 19.minutes
    visit root_path
    expect(page).to have_link 'Sign out'

    Timecop.travel 19.minutes
    visit root_path
    expect(page).to have_link 'Sign out'

    Timecop.travel 21.minutes
    visit root_path
    expect(page).not_to have_link 'Sign out'
    expect(page).to have_content 'Your session expired. Please sign in again to continue.'
  end
end
