FactoryBot.define do
  factory :template do
    sequence :title do |n|
      "template_title_#{n}"
    end
    config do
      {
        fields: [
          { title: 'Email', input_type: 'email', order: 1, name: 'email' },
          { title: 'Password', input_type: 'password', order: 2, name: 'password' }
        ]
      }
    end

    association :user, factory: :user
  end
end
