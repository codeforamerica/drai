module UrlHelpers
  module_function

  def method_missing(method_name, *args, **kwargs, &block)
    return super unless Rails.application.routes.url_helpers.respond_to?(method_name)

    default_url_options = Rails.configuration.action_mailer.default_url_options.clone
    url_options = default_url_options.merge(kwargs)
    Rails.application.routes.url_helpers.send(method_name, *args, **url_options, &block)
  end

  def respond_to_missing?(method_name, *args)
    Rails.application.routes.url_helpers.respond_to?(method_name, *args) || super
  end
end
