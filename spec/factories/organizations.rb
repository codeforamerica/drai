FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    total_payment_cards_count { 10 }
  end
end
