RSpec.describe 'Common requests', type: :request do
  describe 'root' do
    before { get '/', headers: {}, as: :json }
    it 'does not check login' do
      expect(response.body).to eq 'KEYK API v0'
    end
  end
end
