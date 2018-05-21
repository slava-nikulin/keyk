FactoryBot.define do
  factory :note do
    title { Faker::Fallout.faction }

    association :user, factory: :user
  end
end
