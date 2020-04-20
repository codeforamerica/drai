FactoryBot.define do
  factory :new_user, class: User do
    name { Faker::Name.name }
    email { Faker::Internet.email }
  end

  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password' }
    confirmed_at { Time.current }

    organization

    factory :admin do
      admin { true }
      organization { nil }
    end

    factory :assister

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :unsetup do
      password { nil }
      password_confirmation { nil }
    end
  end
end
