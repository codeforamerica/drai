FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    total_payment_cards_count { 10 }
    county_names { ["San Francisco", "Marin"] }
    phone_number { '1234567890' }
  end
end
