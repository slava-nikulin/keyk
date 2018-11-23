RSpec.describe 'Accounts API', type: :request do
  include ActiveJob::TestHelper

  describe 'registration' do
    let(:correct_auth_data) { { account: { login: 'test@test.email', password: 'password' } } }
    let(:incorrect_data) { { account: { login: 'somelogin', password: 'password' } } }

    context 'when register data is valid' do
      it 'returns account in json format' do
        expect { post('/api/v1/account', params: correct_auth_data, as: :json) }
          .to have_enqueued_job.on_queue('mailers')
          .and change { Account.count }.by(1)
        resp = JSON.parse(response.body)
        expect(resp['account']).to be_present
        expect(resp['account']['login']).to eq 'test@test.email'
        expect(resp['account']['confirm_type']).to eq 'email'
        expect { perform_enqueued_jobs { UserMailer.with(account_id: Account.last.id).confirm_email.deliver_later } }
          .to change { ActionMailer::Base.deliveries.size }.by(1)
        expect(response).to have_http_status(200)
      end
    end

    context 'when register data is invalid' do
      before { post '/api/v1/account', params: incorrect_data, as: :json }

      it 'returns errors in json format' do
        resp = JSON.parse(response.body)
        expect(resp['errors'][0]['message']).to eq 'Authorization failed'
        expect(response).to have_http_status(500)
      end
    end

    context 'when register params are empty' do
      before { post '/api/v1/account', params: {}, as: :json }

      it 'returns errors in json format' do
        resp = JSON.parse(response.body)
        expect(resp['errors'][0]['message']).to eq 'Parameters are invalid'
        expect(response).to have_http_status(500)
      end
    end
  end

  describe 'deletion' do
    let!(:account) { create :account, :with_user, :confirmed }
    let(:delete_acc) do
      delete '/api/v1/account', headers: { 'Authorization' => "Token token=#{account.auth_tokens.last.value}" }
    end

    context 'when operation successful' do
      it 'destroys current account' do
        expect { delete_acc }.
          to change { Account.count }.by(-1).
          and change { User.count }.by(-1).
          and change { Token.count }.by(-1)

        resp = JSON.parse(response.body)
        expect(resp['message']).to eq 'Account was destroyed'
        expect(response).to have_http_status(200)
      end
    end

    context 'when operation unsuccessful' do
      before do
        allow_any_instance_of(Account).to receive(:destroy).and_return(false)
        errors = ActiveModel::Errors.new(account)
        errors.add(:base, :destroy, message: 'err_msg')
        allow_any_instance_of(Account).to receive(:errors).and_return(errors)
      end

      it 'destroys current account' do
        expect { delete_acc }.
          to change { Account.count }.by(0).
          and change { User.count }.by(0)

        resp = JSON.parse(response.body)
        expect(resp['errors'][0]['message']).to eq 'err_msg'
        expect(response).to have_http_status(500)
      end
    end
  end
end
