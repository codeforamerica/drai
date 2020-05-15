FactoryBot.define do
  factory :payment_card do
    quote_number { '999999' }
    sequence_number { rand(1000000..9999999) }
    proxy_number { rand(100000000..999999999) }
    card_number { "999-XXXX-XXXX-#{rand(1000..9999)}" }
    client_order_number { rand(10000..99999) }
  end
end
