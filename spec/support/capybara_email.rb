require 'capybara/email/rspec'

module Capybara::Email::DSL
  def open_sms(from)
    open_email PhoneNumberFormatter.format(from)
  end

  alias current_sms current_email
end

RSpec.configure do |config|
  config.include Capybara::Email::DSL

  config.before do |_example|
    clear_emails
  end
end
