require 'csv'

class PaymentCard < ApplicationRecord
  has_paper_trail

  belongs_to :aid_application, optional: true
  has_one :payment_card_order, primary_key: :client_order_number, foreign_key: :client_order_number
  has_one :client_order_organization, through: :payment_card_order, source: :organization

  def self.import(csv_text:, quote_number:)
    if quote_number.blank?
      raise "Missing Quote Number"
    end

    csv = CSV.parse(csv_text, headers: true)

    data = csv.map do |row|
      {
        quote_number: quote_number,
        sequence_number: row.fetch("SEQUENCE #"),
        proxy_number: row["PROXY"] || row["Proxy"] || (raise "missing 'PROXY'"),
        card_number: row.fetch("CLEANSED PAN"),
        client_order_number: row["CLIENT ORDER NUMBER"] || row["HAWK MARKETPLACE ORDER NUMBER"] || (raise "missing 'CLIENT ORDER NUMBER'"),
        created_at: Time.current,
        updated_at: Time.current,
      }
    end

    insert_all(data)
  end

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
