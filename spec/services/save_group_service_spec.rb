RSpec.describe SaveGroupService do
  before { create :account, login: 'test@test.tt', password: 'password' }

  context 'when params are valid' do
    let(:valid_params) { { login: 'test@test.tt', password: 'password' } }

    it 'creates new token' do
      res = {}
      expect { res = described_class.new(valid_params).call }.to change { Token.count }.by(1)
      expect(res.result[:token]).to be_present
      expect(res.valid?).to be_truthy
    end
  end

  context 'when password is invalid' do
    let(:invalid_params) { { login: 'test@test.tt', password: 'wrong_password' } }

    it 'creates new token' do
      res = {}
      expect { res = described_class.new(invalid_params).call }.to change { Token.count }.by(0)
      expect(res.errors.full_messages.to_sentence).to eq 'Authorization failed'
      expect(res.valid?).to be_falsey
    end
  end
end
