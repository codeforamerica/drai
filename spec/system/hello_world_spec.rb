require 'rails_helper'

describe 'Hello World' do
  specify do
    visit root_path
    expect(page).to have_content "Hello World!"
  end
end
