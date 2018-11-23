RSpec.describe 'Authentication API', type: :request do
  let(:correct_auth_data1) { { account: { login: '79889966886', password: 'password' } } }
  let(:correct_auth_data2) { { account: { login: 'test@email.com', password: 'password' } } }

  describe 'login' do
    context 'when login is phone' do
      let!(:account) { create :account, :with_user, login: '79889966886', password: 'password' }
      before { post '/api/v1/sessions', params: correct_auth_data1 }

      it 'returns token' do
        resp = JSON.parse(response.body)
        expect(account.auth_tokens.last.value).to eq resp['token']
      end
    end

    context 'when login is email' do
      let!(:account) { create :account, :with_user, login: 'test@email.com', password: 'password' }
      before { post '/api/v1/sessions', params: correct_auth_data2 }

      it 'returns token' do
        resp = JSON.parse(response.body)
        expect(account.auth_tokens.last.value).to eq resp['token']
      end
    end

    context 'when auth data is invalid' do
      context 'when login is not email or phone' do
        before { post '/api/v1/sessions', params: { account: { login: 'invalid' } } }

        it 'returns corresponding error message' do
          resp = JSON.parse(response.body)
          expect(resp['errors'].any? { |el| el['message'] == 'Authorization failed' }).to be_truthy
        end
      end

      context 'when password is invalid or account does not exist' do
        before { post '/api/v1/sessions', params: { account: { login: '79889966886' } } }

        it 'returns corresponding error message' do
          resp = JSON.parse(response.body)
          expect(resp['errors'].any? { |el| el['message'] == 'Authorization failed' }).to be_truthy
        end
      end
    end
  end

  describe 'sign_out' do
    let!(:account) { create :account, :with_user, :confirmed, login: '79889966886', password: 'password' }

    context 'when token is valid' do
      it 'clears auth_token' do
        expect do
          delete '/api/v1/sessions/sign_out', headers: { 'Authorization' => "Token token=#{account.auth_tokens.last.value}" }
        end.to change { Token.count }.by(-1)

        expect(response).to have_http_status(200)
      end
    end

    context 'when token is invalid' do
      before do
        delete '/api/v1/sessions/sign_out',
               params: {},
               headers: { 'Authorization' => 'Token token=invalid_token' }
      end

      it 'returns 401 status' do
        expect(response).to have_http_status(401)
      end
    end
  end
end
