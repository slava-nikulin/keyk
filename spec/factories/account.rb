FactoryBot.define do
  factory :account do
    login { Faker::Internet.email }
    password { 'password' }

    after(:create) do |acc|
      acc.tokens.create!
    end

    trait :with_reset do
      reset_password_token { SecureRandom.hex(32) }
      reset_password_token_created_at { Time.now }
    end

    trait :with_confirmation do
      confirmation_token { SecureRandom.hex(32) }
      confirmed_at { Time.now }
      confirmation_sent_at { Time.now }
    end

    trait :with_unclock_data do
      failed_attempts { 10 }
      unlock_token { SecureRandom.hex(32) }
      confirmation_sent_at { Time.now }
    end

    trait :with_user do
      after(:create) do |acc, _|
        create(:user, :empty, account: acc, Account.login_key(acc.login) => acc.login)
      end
    end
  end
end
