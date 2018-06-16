RSpec.describe GroupRelationship, type: :model do
  describe 'validation' do
    it { should validate_uniqueness_of(:user_id).scoped_to(:group_id) }
  end

  describe 'associations' do
    it { should belong_to(:group) }
    it { should belong_to(:user) }
  end

  describe 'enum' do
    it { should define_enum_for(:user_role).with(%i(owner editor guest)) }
  end
end
