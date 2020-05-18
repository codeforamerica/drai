Raven.configure do |config|
  config.sanitize_fields = Rails.application.config.filter_parameters.map do |pattern|
    if pattern.is_a? Regexp
      pattern.to_s.match(/:(.*)\)/)[1].gsub(/\\A|\\z|\$|\^/, '')
    else
      pattern.to_s
    end
  end
  config.environments = %w(production demo)
end
