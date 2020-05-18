FactoryBot.define do
  factory :aid_application do
    creator { build :assister }
    organization { creator.organization }

    # Eligibility
    county_name { organization&.county_names&.first }
    no_cbo_association { true }
    covid19_reduced_work_hours { true }
    valid_work_authorization { false }
    attestation { true }

    # Application
    name { Faker::Name.name }
    birthday { 'January 1, 1980' }

    street_address { Faker::Address.street_address }
    city { Faker::Address.city }
    zip_code { '94103' }

    allow_mailing_address { true }
    mailing_street_address { Faker::Address.street_address }
    mailing_city { Faker::Address.city }
    mailing_state { Faker::Address.state }
    mailing_zip_code { '03226' }

    phone_number { Faker::PhoneNumber.cell_phone }
    sms_consent { true }
    landline { false }

    receives_calfresh_or_calworks { true }

    racial_ethnic_identity { [AidApplication::RACIAL_OR_ETHNIC_IDENTITY_OPTIONS.first] }

    card_receipt_method { 'Mail' }

    trait :submitted do
      submitter { creator }
      submitted_at { Time.current }
      application_number { generate_application_number }
    end

    trait :approved do
      submitted

      approver { create :supervisor, organization: organization }
      approved_at { Time.current }
    end

    trait :disbursed do
      approved

      after(:create) do |aid_application, evaluator|
        payment_card = create(:payment_card)
        aid_application.disburse(payment_card, disburser: aid_application.approver)
      end
    end
  end
end
