Capybara.default_max_wait_time = 2
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.include ActionView::RecordIdentifier, type: :system

  config.before(:each, type: :system) do |example|
    if ENV['SHOW_BROWSER']
      example.metadata[:js] = true
      driven_by :selenium, using: :chrome, screen_size: [1024, 800]
    else
      driven_by :rack_test
    end
  end

  config.before(:each, type: :system, js: true) do
    # Chrome's no-sandbox option is required for running in Docker
    driven_by :selenium, using: (ENV['SHOW_BROWSER'] ? :chrome : :headless_chrome), screen_size: [1024, 800], options: { args: ["no-sandbox", "disable-dev-shm-usage"] }
  end

  # When running in a browser, ensure capybara-email links have correct host
  config.around(type: :system) do |example|
    old_mailer_options = ActionMailer::Base.default_url_options
    example.run
    ActionMailer::Base.default_url_options = old_mailer_options
  end

  config.before(type: :system) do |example|
    if example.metadata[:js] || ENV['SHOW_BROWSER']
      ActionMailer::Base.default_url_options = {
        host: Capybara.current_session.server.host,
        port: Capybara.current_session.server.port,
      }
    end
  end
end
