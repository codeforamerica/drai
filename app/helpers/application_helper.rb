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
end
