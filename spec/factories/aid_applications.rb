FactoryBot.define do
  factory :aid_application do
    association :assister, factory: :user
    organization { assister.organization }
  end
end
