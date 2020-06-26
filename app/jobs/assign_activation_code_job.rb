class AssignActivationCodeJob < ApplicationJob
  MissingAidApplication = Class.new(StandardError)
  MissingActivationCode = Class.new(StandardError)
  PaymentCardAlreadyAssigned = Class.new(StandardError)
  ApiFailureError = Class.new(StandardError)

  def perform(payment_card:, message_client: true, allow_reassignment: false)
    raise MissingAidApplication if payment_card.aid_application.blank?
    raise MissingActivationCode if payment_card.activation_code.blank?

    unless allow_reassignment
      raise PaymentCardAlreadyAssigned if payment_card.blackhawk_activation_code_assigned_at.present?
    end

    result = BlackhawkApi.activate(
      quote_number: payment_card.quote_number,
      proxy_number: payment_card.proxy_number,
      activation_code: payment_card.activation_code
    )

    if result
      payment_card.update!(blackhawk_activation_code_assigned_at: Time.current)
      payment_card.aid_application.send_disbursement_notification if message_client
    else
      raise ApiFailureError
    end
  end
end
