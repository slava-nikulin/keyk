FactoryBot.define do
  factory :note do
    title { Faker::Fallout.faction }

    association :template, factory: :template
    association :user, factory: :user
  end
end
