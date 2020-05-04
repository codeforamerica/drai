class BlackhawkApi
  def self.activate(quote_number:, proxy_number:, activation_code:)
    return if Rails.application.secrets.blackhawk_client_id.blank? && Rails.application.secrets.blackhawk_client_secret.blank?

    new(
      client_id: Rails.application.secrets.blackhawk_client_id,
      client_secret: Rails.application.secrets.blackhawk_client_secret
    ).activate(
      quote_number: quote_number,
      proxy_number: proxy_number,
      activation_code: activation_code
    )
  end

  def initialize(client_id:, client_secret:)
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
      "https://certification.marketplace.bhnapi.com/cards/v1/set-activation-codes",
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
      "https://certification.marketplace.bhnapi.com/cards/monitor",
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
    request = Typhoeus.post(
      "https://certification.marketplace.bhnapi.com/api/auth",
      headers: {
        'Content-Type' => "application/x-www-form-urlencoded",
        'Accept' => 'application/json'
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
end
