RSpec.describe 'Groups API', type: :request do
  let(:group_owner) { create :user }
  let(:user1) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }
  let(:note1) { create :note }
  let(:note2) { create :note }
  let(:note3) { create :note }
  let!(:group) { create(:group, notes: [note1, note2, note3], guests: [user1, user2, user3], owners: [group_owner]) }
  let(:valid_params) do
    {
      title: 'Test group',
      users: [
        { login: user1.account.login },
        { login: user2.account.login },
        { login: user3.account.login, _destroy: 1 },
      ],
      notes: [
        { id: note1.id },
        { id: note2.id },
        { id: note3.id, _destroy: 1 },
      ],
    }
  end

  describe 'GET api/v1/groups' do
    before do
      get '/api/v1/groups', headers: auth_header(group_owner.account.tokens.last), as: :json
    end

    it 'returns templates list' do
      res = JSON.parse(response.body)
      expect(res['groups'][0]['id']).to eq group.id
    end
  end

  describe 'GET api/v1/groups/:id' do
    before do
      get "/api/v1/groups/#{group.id}", headers: auth_header(group_owner.account.tokens.last), as: :json
    end

    it 'returns group in json format' do
      res = JSON.parse(response.body)
      expect(res['group']['id']).to eq group.id
      expect(res['group']['owners'][0]['login']).to eq group_owner.account.login
      expect(res['group']['owners'][0]['id']).to eq group_owner.id
      expect(res['group']['guests'].count).to eq 3
    end
  end

  describe 'POST api/v1/groups/' do
    before do
      post '/api/v1/groups/',
          params: { group: valid_params },
          headers: auth_header(group_owner.account.tokens.last),
          as: :json
    end

    it 'creates group' do
      res = JSON.parse(response.body)
      expect(res['group']['title']).to eq 'Test group'
      expect(res['group']['owners'].count).to eq 1
      expect(res['group']['owners'][0]['id']).to eq group_owner.id
      expect(res['group']['guests'].count).to eq 2
      expect(res['group']['notes'].count).to eq 2
    end
  end

  describe 'PATCH api/v1/templates/' do
    let(:group_params) do
      {
        title: 'test',
        users: [
          { login: user2.account.login, user_role: 'editor' },
          { login: user3.account.login, _destroy: 1 }
        ],
        notes: [
          { id: note1.id, _destroy: 1 }
        ],
      }
    end

    context 'when id is valid' do
      before do
        patch "/api/v1/groups/#{group.id}",
          params: { group: group_params },
          headers: auth_header(group_owner.account.tokens.last),
          as: :json
      end

      it 'updates template' do
        res = JSON.parse(response.body)
        expect(res['group']['owners'].count).to eq 1
        expect(res['group']['editors'].count).to eq 1
        expect(res['group']['guests'].count).to eq 1
        expect(res['group']['title']).to eq 'test'
      end
    end

    context 'when id is not valid' do
      before do
        patch "/api/v1/groups/#{group.id + 100}",
          params: { group: group_params },
          headers: auth_header(group_owner.account.tokens.last),
          as: :json
      end

      it 'returns 404 not found' do
        expect(response).to have_http_status(404)
      end
    end
  end
end
