RSpec.describe ConfirmAccountService do
  let(:acc) { create :account }
  before { acc.create_confirm_token! }
  let(:valid_params) do
    {
      login: acc.login,
      confirm_token: acc.confirm_token.value
    }
  end

  context 'when parameters are valid' do
    it 'makes user confirmed' do
      res = {}
      expect { res = described_class.new(valid_params).call }.to change { acc.reload.confirmed_at }
      expect(res).to be_valid
      expect(res.result[:token]).to be_present
      expect(res.result[:account].id).to eq acc.id
    end
  end

  context 'when token expired' do
    before { acc.create_confirm_token!(updated_at: Date.today - 100.days) }

    it 'returns error' do
      res = {}
      expect { res = described_class.new(valid_params).call }.not_to change { acc.reload.confirmed_at }
      expect(res).not_to be_valid
    end
  end
end
