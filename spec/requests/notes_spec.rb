RSpec.describe 'Notes API', type: :request do
  let(:user) { create :user, account: create(:account, :confirmed) }
  let!(:note1) { create :note, user: user }
  let!(:note2) { create :note, :with_fields, user: user }
  let(:headers) { { 'Authorization' => "Token token=#{user.account.auth_tokens.last.value}" } }

  describe 'GET api/v1/notes' do
    before do
      get '/api/v1/notes', headers: headers, as: :json
    end

    it 'returns notes list' do
      res = JSON.parse(response.body)
      expect(res['notes'].count).to eq 2
      expect(res['notes'][0]['title']).to eq note1.title
    end
  end

  describe 'POST api/v1/notes' do
    let(:create_note_params) do
      {
        note: {
          title: 'new_note',
          order: 1,
          fields_attributes: [
            input_type: 'password',
            title: 'Pass',
            name: 'pass',
            order: 1,
            value: 'test'
          ]
        }
      }
    end

    before do
      post('/api/v1/notes', params: create_note_params, headers: headers, as: :json)
    end

    it 'creates new note' do
      res = JSON.parse(response.body)
      expect(res['note']['title']).to eq 'new_note'
      expect(res['note']['fields'][0]['name']).to eq 'pass'
    end
  end

  describe 'GET /api/v1/notes/:id' do
    before do
      get "/api/v1/notes/#{note2.id}", headers: headers, as: :json
    end

    it 'returns detailed note info' do
      res = JSON.parse(response.body)
      expect(res['note']['fields'].count).to eq 2
    end
  end

  describe 'PATCH /api/v1/notes/:id' do
    let(:update_note_params) do
      {
        note: {
          title: 'update_note',
          order: 2,
          fields_attributes: [
            {
              id: note2.fields.first.id,
              _destroy: 1
            },
            {
              id: note2.fields.last.id,
              name: 'email111',
              title: 'EMAIL TITLE'
            }
          ]
        }
      }
    end

    before do
      patch "/api/v1/notes/#{note2.id}", params: update_note_params, headers: headers, as: :json
    end

    it 'updates note with parameters' do
      res = JSON.parse(response.body)
      expect(res['note']['fields'].count).to eq 1
      expect(res['note']['title']).to eq 'update_note'
    end
  end

  describe 'DELETE /api/v1/notes/:id' do
    it 'deletes note' do
      expect do
        delete "/api/v1/notes/#{note1.id}", headers: headers, as: :json
      end.to change { Note.count }.by(-1)
    end
  end
end
