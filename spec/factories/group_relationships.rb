FactoryBot.define do
  factory :group_relationship do
    user_role { 'owner' }

    association :user, factory: :user
    association :group, factory: :group
  end
end
