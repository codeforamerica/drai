Rails.application.configure do
  config.lograge.enabled = ActiveModel::Type::Boolean.new.cast(ENV['LOGRAGE_ENABLED'])
  config.lograge.logger = Rails.logger

  lograge_format = ENV['LOGRAGE_FORMAT']
  if lograge_format.present?
    config.lograge.log_format = lograge_format
  end

  params_to_skip = %w[controller action format id].freeze
  config.lograge.custom_options = lambda do |event|
    event.payload.slice(
      :environment,
      :remote_ip,
      :user_id,
      :organization_id,
      :aid_application_id
    ).merge(
      params: event.payload[:params].except(*params_to_skip)
    )
  end

  if config.lograge.enabled
    config.colorize_logging = false
  end
end
