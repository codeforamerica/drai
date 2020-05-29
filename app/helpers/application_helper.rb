module ApplicationHelper
  def capture_form(&block)
    lambda do |form|
      capture do
        block.call(form)
      end
    end
  end

  def current_path?(options)
    raise 'You cannot use helpers that need to determine the current page unless your view context provides a Request object in a #request method' unless request

    url_string = URI.parser.unescape(url_for(options)).force_encoding(Encoding::BINARY)

    # We ignore any extra parameters in the request_uri if the
    # submitted url doesn't have any either. This lets the function
    # work with things like ?order=asc
    request_uri = url_string.index('?') ? request.fullpath : request.path
    request_uri = URI.parser.unescape(request_uri).force_encoding(Encoding::BINARY)

    url_string == if url_string.match?(/^\w+:\/\//)
                    "#{request.protocol}#{request.host_with_port}#{request_uri}"
                  else
                    request_uri
                  end
  end

  def supervisor?
    current_user.try(:supervisor?) || current_user.try(:admin?)
  end

  def activation_code_notification_description(aid_application)
    if aid_application.sms_consent? && aid_application.email_consent?
      html_output = <<~HTML
        <span>text message at <strong>#{add_dashes_to_phone_number(aid_application.phone_number)}</strong> and email at <strong>#{aid_application.email}.</strong></span>
      HTML
    elsif aid_application.sms_consent?
      html_output = <<~HTML
        <span>text message at <strong>#{add_dashes_to_phone_number(aid_application.phone_number)}.</strong></span>
      HTML
    elsif aid_application.email_consent?
      html_output = <<~HTML
        <span>email at <strong>#{aid_application.email}.</strong></span>
      HTML
    else
      html_output = <<~HTML
        <span><strong>No contact info.</strong></span>
      HTML
    end

    html_output.html_safe
  end

  def add_dashes_to_phone_number(phone_number)
    phone_number.match(/(\d{3})(\d{3})(\d{4})/)
      [$1, $2, $3].join("-")
  end

  def translate(key, **options)
    translation = super(key, **options)
    if translation.present? && I18n.locale != :en && translation == super(key, **options.merge(locale: :en))
      "<bdo dir=\"ltr\" class=\"translation-fallback\">#{translation}</bdo>".html_safe
    else
      translation
    end
  end
  alias t translate
end
