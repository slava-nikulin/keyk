FactoryBot.define do
  factory :account do
    login { Faker::Internet.email }
    password { 'password' }

    after(:create) do |acc|
      acc.auth_tokens.create!
    end

    trait :confirmed do
      after(:create) do |acc, _|
        acc.update_attributes!(confirmed_at: Time.zone.now)
      end
    end

    trait :with_reset do
      after(:create) do |acc, _|
        acc.reset_token = Token.create!
      end
    end

    trait :with_confirmation do
      after(:create) do |acc, _|
        acc.confirm_token = Token.create!
      end
    end

    trait :with_user do
      after(:create) do |acc, _|
        create(:user, :empty, account: acc, Account.login_key(acc.login) => acc.login)
      end
    end
  end
end
