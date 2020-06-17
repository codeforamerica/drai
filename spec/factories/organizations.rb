FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    slug { name.parameterize(separator: '_') }
    total_payment_cards_count { 10 }
    county_names { ["San Francisco", "Marin"] }
    contact_information { '(123) 456-7890' }
  end
end
