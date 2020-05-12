FactoryBot.define do
  factory :aid_application do
    creator { build :assister }
    organization { creator.organization }

    name { Faker::Name.name }
    birthday { 'January 1, 1980' }

    street_address { Faker::Address.street_address }
    city { Faker::Address.city }
    zip_code { '94103' }

    allow_mailing_address { true }
    mailing_street_address { Faker::Address.street_address }
    mailing_city { Faker::Address.city }
    mailing_zip_code { '03226' }

    preferred_contact_channel { 'text' }
    phone_number { Faker::PhoneNumber.cell_phone }

    receives_calfresh_or_calworks { true }

    racial_ethnic_identity { [AidApplication::RACIAL_OR_ETHNIC_IDENTITY_OPTIONS.first] }

    trait :submitted do
      submitter { creator }
      submitted_at { Time.current }
      application_number { generate_application_number }
    end
  end
end
