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

    members { build_list(:member, members_count, aid_application: nil) }

  end
end
