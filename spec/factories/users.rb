FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    sequence :phone do |n|
      "7989555#{format('%04d', n)}"
    end
    association :account, factory: :account

    trait :empty do
      email nil
      phone nil
    end
  end
end
