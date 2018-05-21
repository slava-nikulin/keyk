RSpec.describe Token, type: :model do
  subject { build(:token) }

  describe 'db' do
    it { should have_db_column(:value).of_type(:string) }
    it { should have_db_column(:account_id).of_type(:integer) }
  end

  describe 'validation' do
    it { should validate_presence_of(:account) }
    it { should validate_uniqueness_of(:value).ignoring_case_sensitivity }
  end

  describe 'association' do
    it { should belong_to(:account) }
  end

  describe 'callbacks' do
    describe 'after_create' do
      let (:token) { build(:token) }

      it 'generates token value after saving' do
        expect { token.save }.to change { token.value }
        expect(token.value).to be_present
      end
    end
  end
end
