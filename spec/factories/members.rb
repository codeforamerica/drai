FactoryBot.define do
  factory :member do
    name { Faker::Name.name }
    birthday { 'January 1, 1980' }

    aid_application
  end
end
