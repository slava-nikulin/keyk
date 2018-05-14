RSpec.describe Group, type: :model do
  describe 'validation' do
    it { should validate_presence_of(:title) }
  end

  describe 'associations' do
    it { should have_and_belong_to_many(:notes) }
    it { should have_many(:group_relationships) }
    it { should have_many(:users).through(:group_relationships) }
  end
end
