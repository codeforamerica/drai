FactoryBot.define do
  factory :payment_card do
    quote_number { '999999' }
    sequence_number { rand(1000000..9999999) }
    proxy_number { rand(100000000..999999999) }
    card_number { "999-XXXX-XXXX-#{rand(1000..9999)}" }
    client_order_number { rand(10000..99999) }

    trait :disbursed do
      activation_code { generate_activation_code }
      blackhawk_activation_code_assigned_at { Time.current }
      aid_application { create :aid_application, :disbursed, payment_card: nil }
    end
  end
end
