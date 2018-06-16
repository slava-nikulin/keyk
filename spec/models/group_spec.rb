RSpec.describe Group, type: :model do
  describe 'validation' do
    it { should validate_presence_of(:title) }
  end

  describe 'associations' do
    it { should have_and_belong_to_many(:notes) }
    it { should have_many(:group_relationships) }
    it { should have_many(:users).through(:group_relationships) }
  end

  describe 'methods' do
    let(:user1) { create :user }
    let(:user2) { create :user }
    let(:group) { create :group }
    let!(:gr_rel) { create :group_relationship, user: user1, group: group }

    describe '#has_owner?' do
      it 'checks if user is owner of group' do
        expect(group.has_owner?(user1.id)).to be_truthy
        expect(group.has_owner?(user2.id)).to be_falsey
      end
    end
  end
end
