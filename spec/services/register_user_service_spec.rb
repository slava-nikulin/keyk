RSpec.describe RegisterUserService do
  context 'when params are valid' do
    let(:valid_params) do
      {
        login: 'test@test.com',
        password: 'password'
      }
    end

    it 'creates new account with user' do
      res = {}
      expect { res = described_class.new(valid_params).call }.
        to change { Account.count }.by(1).
        and change { User.count }.by(1)
      expect(res.result[:account].user.email).to eq 'test@test.com'
      expect(res.valid?).to be_truthy
    end
  end

  context 'when user with same login exists' do
    let(:valid_params) do
      {
        login: 'test@test.com',
        password: 'password'
      }
    end

    context 'when existed user confirmed' do
      before { create :account, login: 'test@test.com', confirmed_at: Time.zone.now }

      it 'does not allow to register account' do
        res = {}
        expect { res = described_class.new(valid_params).call }.
          to change { Account.count }.by(0).
          and change { User.count }.by(0)
        expect(res.errors.count).to eq 1
        expect(res.errors.full_messages.to_sentence).to eq 'Login has been already taken'
        expect(res.valid?).to be_falsey
      end
    end

    context 'when existed user was not confirmed, confirm_token is expired' do
      let(:acc) { create :account, :with_user, login: 'test@test.com' }
      before { acc.create_confirm_token!(updated_at: Date.today - 100.days) }

      it 'allows to take that login' do
        res = {}
        expect { res = described_class.new(valid_params).call }.
          to change { Account.count }.by(0).
          and change { User.count }.by(0)
        expect(res.valid?).to be_truthy
        expect(res.result[:account].password_digest).not_to eq acc.password_digest
      end
    end

    context 'when existed user was not confirmed, confirm_token is NOT expired' do
      let(:acc) { create :account, :with_user, login: 'test@test.com' }
      before { acc.create_confirm_token!(updated_at: Date.today) }

      it 'allows to take that login' do
        res = {}
        expect { res = described_class.new(valid_params).call }.
          to change { Account.count }.by(0).
          and change { User.count }.by(0)
        expect(res.errors.count).to eq 1
        expect(res.errors.full_messages.to_sentence).to eq 'Login has been already taken'
        expect(res.valid?).to be_falsey
      end
    end
  end

  context 'when login is invalid' do
    let(:invalid_login_params) do
      {
        login: 'some string',
        password: 'password'
      }
    end

    it 'returns corresponding error message' do
      res = {}
      expect { res = described_class.new(invalid_login_params).call }.
        to change { Account.count }.by(0).
        and change { User.count }.by(0)
      expect(res.errors.count).to eq 1
      expect(res.valid?).to be_falsey
    end
  end
end
