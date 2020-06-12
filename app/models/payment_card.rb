class PaymentCard < ApplicationRecord
  has_paper_trail

  belongs_to :aid_application, optional: true

  def generate_activation_code
    rand(100000..999999)
  end

  def replace_with(right_card)
    if right_card.aid_application.present?
      raise "right card already assigned to an aid application"
    end

    preserved_activation_code = activation_code
    preserved_aid_application = aid_application

    if preserved_activation_code.blank? || preserved_aid_application.blank?
      raise "cannot replace an unassigned payment card"
    end

    PaymentCard.transaction(joinable: false, requires_new: true) do
      update!(activation_code: nil, aid_application: nil, blackhawk_activation_code_assigned_at: nil)
      right_card.update!(activation_code: preserved_activation_code, aid_application: preserved_aid_application)
    end

    AssignActivationCodeJob.perform_now(payment_card: right_card)
  end
end
