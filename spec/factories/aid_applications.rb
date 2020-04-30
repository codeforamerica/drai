FactoryBot.define do
  factory :aid_application do
    assister
    organization { assister.organization }

    street_address { Faker::Address.street_address }
    city { Faker::Address.city }
    zip_code { '94103' }

    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.cell_phone }

    transient do
      members_count { 2 }
    end

    after(:build) do |aid_application, evaluator|
      if evaluator.members_count > 0
        aid_application.members = build_list(:member, evaluator.members_count, aid_application: aid_application)
      end
    end
  end
end
