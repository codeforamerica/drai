source 'https://rubygems.org'
ruby '2.6.6'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'cfa-styleguide', git: 'https://github.com/codeforamerica/honeycrisp-gem', branch: 'fix-broken-path-finder-in-rails-6'
gem 'devise'
gem 'jbuilder', '~> 2.7'
gem 'pg', '>= 0.18', '< 2.0'
gem 'pry-rails'
gem 'puma', '~> 4.1'
gem 'rails', '~> 6.0.2', '>= 6.0.2.2'
gem 'sass-rails', '>= 6'
gem 'sentry-raven'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
end

group :development do
  gem 'annotate'
  gem 'eefgilm'
  gem 'lintstyle', github: 'bensheldon/lintstyle'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara'
  gem 'capybara-email'
  gem 'climate_control'
  gem 'launchy', require: false
  gem 'selenium-webdriver'
  gem 'webmock'
end
