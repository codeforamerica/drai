FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }
    confirmed_at { Time.current }

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :unsetup do
      password { nil }
      password_confirmation { nil }
    end
  end
end
