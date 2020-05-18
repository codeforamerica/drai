class BlackhawkApi
  PRODUCTION_HOST = 'https://marketplace.bhnapi.com'
  CERTIFICATION_HOST = 'https://certification.marketplace.bhnapi.com'

  PRODUCTION_IVR = '1-877-610-1075'
  CERTIFICATION_IVR = '1-925-474-3705'

  def self.api_host
    if Rails.env.production?
      PRODUCTION_HOST
    else
      CERTIFICATION_HOST
    end
  end

  def self.ivr_phone_number
    if Rails.env.production?
      PRODUCTION_IVR
    else
      CERTIFICATION_IVR
    end
  end

  def self.activate(quote_number:, proxy_number:, activation_code:)
    return true if (Rails.env.development? && Rails.application.secrets.blackhawk_client_id.blank?)

    new.activate(
      quote_number: quote_number,
      proxy_number: proxy_number,
      activation_code: activation_code
    )
  end

  def initialize(
    client_id: Rails.application.secrets.blackhawk_client_id,
    client_secret: Rails.application.secrets.blackhawk_client_secret
  )
    @client_id = client_id
    @client_secret = client_secret
    @access_token = nil
  end

  def activate(quote_number:, proxy_number:, activation_code:)
    body_json = [{
                   "quoteNumber": quote_number,
                   "proxyNumber": proxy_number,
                   "activationCode": activation_code
                 }]
    request = Typhoeus.post(
      "#{api_host}/cards/v1/set-activation-codes",
      headers: {
        'Authorization': "Bearer #{access_token}",
        'accept': 'application/json',
        'Content-Type': "application/json",
      },
      body: body_json.to_json
    )

    response_body = JSON.parse request.response_body
    response_body.fetch('success')
  end

  def monitor
    request = Typhoeus.get(
      "#{api_host}/cards/monitor",
      headers: {
        'Authorization': "Bearer #{access_token}",
        'accept': 'application/json',
        'Content-Type': "application/json",
      }
    )

    response_body = JSON.parse request.response_body
    response_body.fetch('status') == 'SUCCESS'
  end

  def authenticate
    # FYI, headers only work consistently with lowercase keys
    request = Typhoeus.post(
      "#{api_host}/api/auth",
      headers: {
        'content-type' => "application/x-www-form-urlencoded",
        'accept' => 'application/json'
      },
      body: { grant_type: 'client_credentials' },
      userpwd: "#{@client_id}:#{@client_secret}"
    )

    response_body = JSON.parse(request.response_body)
    @access_token = response_body.fetch('access_token')
  end

  def access_token
    authenticate if @access_token.blank?

    @access_token
  end

  def api_host
    self.class.api_host
  end
end
