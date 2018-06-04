FactoryBot.define do
  factory :field do
    input_type { Field.input_types.values.sample }
    title { 'Login' }
    name { Faker::Hacker.noun }
    sequence :order do |n|
      n
    end
    value { Faker::Cannabis.terpene }

    association :note, factory: :note
  end
end
