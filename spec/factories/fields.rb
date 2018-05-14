FactoryBot.define do
  factory :field do
    input_type { 0 }
    title { 'Login' }
    name { Faker::Hacker.noun }
    order { 1 }

    association :note, factory: :note
  end
end
