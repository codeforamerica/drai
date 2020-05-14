class AssignActivationCodeJob < ApplicationJob
  def perform(aid_application:)
    payment_card = aid_application.payment_card
    return if payment_card.blank?

    return if payment_card.activation_code_assigned_at.present?

    result = BlackhawkApi.activate(
      quote_number: payment_card.quote_number,
      proxy_number: payment_card.proxy_number,
      activation_code: aid_application.activation_code
    )

    if result
      payment_card.update!(
        activation_code: aid_application.activation_code,
        activation_code_assigned_at: Time.current
      )
    end
  end
end
