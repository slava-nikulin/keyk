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
    let(:user3) { create :user }
    let(:group) { create :group, owners: [user1], guests: [user2], editors: [user3] }

    describe '#has_owner?' do
      it 'checks if user is owner of group' do
        expect(group.has_owner?(user1.id)).to be_truthy
        expect(group.has_owner?(user2.id)).to be_falsey
      end
    end

    describe '#owners' do
      it 'returns owners of the group' do
        expect(group.owners[0]).to eq user1
      end
    end

    describe '#guests' do
      it 'returns guests of the group' do
        expect(group.guests[0]).to eq user2
      end
    end

    describe '#editors' do
      it 'returns editors of the group' do
        expect(group.editors[0]).to eq user3
      end
    end
  end
end
