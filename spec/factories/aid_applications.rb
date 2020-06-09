FactoryBot.define do
  factory :new_aid_application, class: AidApplication do
    creator { build :assister }
    organization { creator.organization }
  end

  factory :eligible_aid_application, parent: :new_aid_application do
    county_name { organization&.county_names&.sample }
    no_cbo_association { true }
    covid19_reduced_work_hours { true }
    valid_work_authorization { false }
    attestation { true }
  end

  factory :aid_application, parent: :eligible_aid_application do
    transient do
      supervisor { organization.supervisors.sample || create(:supervisor, organization: organization) }
    end

    # Application
    name { Faker::Name.name }
    birthday { 'January 1, 1980' }

    street_address { Faker::Address.street_address }
    city { Faker::Address.city }
    zip_code { ZipCode.from_county(county_name)&.sample }

    allow_mailing_address { true }
    mailing_street_address { Faker::Address.street_address }
    mailing_city { Faker::Address.city }
    mailing_state { Faker::Address.state }
    mailing_zip_code { '03226' }

    unmet_housing { true }

    sms_consent { true }
    phone_number { "1234567890" }
    landline { false }

    email_consent { true }
    email { Faker::Internet.email(name: name, domain: 'example.com') }

    receives_calfresh_or_calworks { true }

    racial_ethnic_identity { [AidApplication::RACIAL_OR_ETHNIC_IDENTITY_OPTIONS.first] }

    card_receipt_method { AidApplication::CARD_RECEIPT_MAIL }

    trait :submitted do
      submitter { creator }
      submitted_at { Time.current }
      application_number { generate_application_number }
    end

    trait :approved do
      submitted

      approver { supervisor }
      approved_at { Time.current }
    end

    trait :rejected do
      submitted

      rejecter { supervisor }
      rejected_at { Time.current }
    end

    trait :paused do
      submitted

      submitted_at { 10.days.ago }
      paused_at { submitted_at + 7.days }
    end

    trait :unpaused do
      paused

      paused_at { nil }
      unpaused_at { submitted_at + 8.days }
      unpauser { supervisor }
    end

    trait :disbursed do
      approved

      disburser { supervisor }
      disbursed_at { Time.current }

      after(:create) do |aid_application, evaluator|
        payment_card = create(:payment_card)
        aid_application.disburse(payment_card, disburser: aid_application.approver)
      end
    end
  end
end
