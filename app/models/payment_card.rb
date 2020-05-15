class PaymentCard < ApplicationRecord
  has_paper_trail

  belongs_to :aid_application, optional: true

  def generate_activation_code
    rand(100000..999999)
  end
end
