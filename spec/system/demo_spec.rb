require 'rails_helper'

describe 'Deactivate Users', type: :system do
  context 'when in demo environment' do
    around do |example|
      ClimateControl.modify DEMO_MODE: 'true' do
        example.run
      end
    end

    it 'shows the DEMO banner' do
      visit root_path
      expect(page).to have_content 'This site is for demonstration purposes only.'
    end
  end

  context 'when NOT in demo environment' do
    it 'does not show demo banner' do
      visit root_path
      expect(page).not_to have_content 'This site is for example purposes only'
    end
  end
end
