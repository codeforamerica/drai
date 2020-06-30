class PaymentCardOrder < ApplicationRecord
  belongs_to :organization
  has_many :payment_cards, primary_key: :client_order_number, foreign_key: :client_order_number
end
