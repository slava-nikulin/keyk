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

  context 'when login is already used' do
    let(:invalid_login_params) do
      {
        login: 'test@test.com',
        password: 'password'
      }
    end

    before { create :account, :with_user, login: 'test@test.com' }

    it 'returns corresponding error message' do
      res = {}
      expect { res = described_class.new(invalid_login_params).call }.
        to change { Account.count }.by(0).
        and change { User.count }.by(0)
      expect(res.valid?).to be_falsey
      expect(res.errors.count).to eq 1
    end
  end
end
