FactoryBot.define do
  factory :note do
    title { Faker::Fallout.faction }

    trait :with_fields do
      before(:create) do |note|
        2.times do
          note.fields << build(:field, note: note)
        end
      end
    end

    association :user, factory: :user
  end
end
