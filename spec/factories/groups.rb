FactoryBot.define do
  factory :group do
    transient do
      owners []
      editors []
      guests []
    end

    title { Faker::Dune.title }

    after(:create) do |group, evaluator|
      GroupRelationship.user_roles.keys.each do |role|
        evaluator.send("#{role}s").each do |user|
          group.group_relationships.create!(user: user, user_role: role)
        end
      end
    end
  end
end
