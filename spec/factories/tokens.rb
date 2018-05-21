FactoryBot.define do
  factory :token do
    association :account, factory: :account
  end
end
