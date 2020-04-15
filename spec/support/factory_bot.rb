RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.reload
  end

  config.after do
    FactoryBot.rewind_sequences
  end
end
