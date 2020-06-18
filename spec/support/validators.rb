RSpec.configure do |config|
  config.before(:each) do
    allow(TwilioPhoneNumberValidator).to receive(:valid?).and_return(true)
  end
end
