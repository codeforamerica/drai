require 'rails_helper'

describe 'Privacy page' do
  specify do
    visit "/privacy"
    expect(page).to have_content "Code for America Disaster Relief Aid Notifications Policy"
  end
end
