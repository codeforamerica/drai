require 'capybara/email/rspec'

RSpec.configure do |config|
  config.include Capybara::Email::DSL

  config.before do |_example|
    clear_emails
  end
end
