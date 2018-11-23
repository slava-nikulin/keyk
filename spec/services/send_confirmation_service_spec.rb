RSpec.describe SendConfirmationService do
  context 'when parameters are valid' do
    context 'when login is email' do
      let!(:acc) { create :account, login: 'example@mail.com' }

      it 'sends confirmation email' do
        res = {}
        expect { res = described_class.new(acc.id).call }.to have_enqueued_job.on_queue('mailers')
        expect(res.result[:confirm_type]).to eq :email
        expect(res.valid?).to be_truthy
      end
    end

    context 'when login is phone number' do
      let!(:acc) { create :account, login: '798889966888' }

      it 'sends confirmation sms code' do
        expect { described_class.new(acc.id).call }.to raise_error(NotImplementedError)
      end
    end
  end

  context 'when parameters are invalid' do
    it 'returns error' do
      res = described_class.new(0).call
      expect(res.valid?).to be_falsey
      expect(res.errors.count).to eq 1
    end
  end
end
