Rails.application.config.generators do |g|
  g.test_framework :rspec,
                   fixture: true,
                   views: false,
                   fixture_replacement: :factory_bot,
                   view_specs: false
  g.fixture_replacement :factory_bot, dir: 'spec/factories'
  g.helper false
  g.assets false
  g.javascripts false
  g.stylesheets false
  g.view_specs false
  g.request_specs false
  g.routing_specs false
  g.jbuilder false
end
