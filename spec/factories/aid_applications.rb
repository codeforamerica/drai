FactoryBot.define do
  factory :aid_application do
    creator { build :assister }
    organization { creator.organization }

    street_address { Faker::Address.street_address }
    city { Faker::Address.city }
    zip_code { '94103' }

    preferred_contact_channel { 'text' }
    phone_number { Faker::PhoneNumber.cell_phone }

    receives_calfresh_or_calworks { true }

    transient do
      members_count { 2 }
    end

    after(:build) do |aid_application, evaluator|
      aid_application.members = build_list(:member, evaluator.members_count, aid_application: aid_application)
    end

    trait :submitted do
      submitter { creator }
      submitted_at { Time.current }
      application_number { generate_application_number }
    end
  end
end
