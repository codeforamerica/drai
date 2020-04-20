FactoryBot.define do
  factory :aid_application do
    assister
    organization { assister.organization }
  end
end
