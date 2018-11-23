RSpec.describe 'Templates API', type: :request do
  let(:account) { create :account, :with_user, :confirmed }
  let!(:template1) { create :template, user: account.user }
  let!(:template2) { create :template, user: account.user }

  describe 'GET api/v1/templates' do
    before do
      get '/api/v1/templates', headers: { 'Authorization' => "Token token=#{account.auth_tokens.last.value}" }, as: :json
    end

    it 'returns templates list' do
      res = JSON.parse(response.body)
      expect(res['templates'].count).to eq 2
    end
  end

  describe 'GET api/v1/templates/:show' do
    before do
      get "/api/v1/templates/#{template1.id}",
          headers: { 'Authorization' => "Token token=#{account.auth_tokens.last.value}" },
          as: :json
    end

    it 'returns template in json format' do
      res = JSON.parse(response.body)
      expect(res['template']['id']).to eq template1.id
      expect(res['template']['config']['fields']).
        to eq [
          { 'name' => 'email', 'title' => 'Email', 'input_type' => 'email', 'order' => 1 },
          { 'name' => 'password', 'title' => 'Password', 'input_type' => 'password', 'order' => 2 }
        ]
    end
  end

  describe 'POST api/v1/templates/' do
    let(:template_params) do
      {
        title: 'test',
        config: { fields: [{ name: 'email1', title: 'Type email', input_type: 'text' }] }
      }
    end
    before do
      post '/api/v1/templates/',
          params: { template: template_params },
          headers: { 'Authorization' => "Token token=#{account.auth_tokens.last.value}" },
          as: :json
    end

    it 'creates template' do
      res = JSON.parse(response.body)
      expect(res['template']['title']).to eq 'test'
      expect(res['template']['config']['fields'][0]).
        to eq('name' => 'email1', 'title' => 'Type email', 'input_type' => 'text', 'order' => nil)
    end
  end

  describe 'PATCH api/v1/templates/' do
    let(:template_params) do
      {
        title: 'test'
      }
    end

    context 'when id is valid' do
      before do
        patch "/api/v1/templates/#{template1.id}",
          params: { template: template_params },
          headers: { 'Authorization' => "Token token=#{account.auth_tokens.last.value}" },
          as: :json
      end

      it 'updates template' do
        res = JSON.parse(response.body)
        expect(res['template']['title']).to eq 'test'
      end
    end

    context 'when id is not valid' do
      before do
        patch "/api/v1/templates/#{template1.id + 100}",
          params: { template: template_params },
          headers: { 'Authorization' => "Token token=#{account.auth_tokens.last.value}" },
          as: :json
      end

      it 'returns 404 not found' do
        expect(response).to have_http_status(404)
      end
    end
  end
end
