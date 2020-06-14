# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  /\Aname\z/,
  /\Abirthday\z/,
  /\Aphone_number\z/,
  /\Aemail\z/,
  /\Astreet_address\z/,
  /\Aapartment_number\z/,
  /\Amailing_street_address\z/,
  /\Amailing_apartment_number\z/,
  /\Acard_number\z/,
  :password,
  :password_confirmation,
  :csv_text,
]
