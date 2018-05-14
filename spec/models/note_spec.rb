RSpec.describe Note, type: :model do
  describe 'db' do
    it { should have_db_column(:title).of_type(:string) }
  end

  describe 'validation' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:user) }
  end

  describe 'association' do
    it { should have_many(:fields).dependent(:destroy).autosave(true) }
    it { should belong_to(:user) }
    it { should belong_to(:template) }
    it { should have_and_belong_to_many(:groups) }
  end
end
