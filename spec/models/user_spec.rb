RSpec.describe User, type: :model do
  let(:acc) { create :account }
  subject(:usr) { build :user, :empty, account: acc }

  describe 'db' do
    it { should have_db_column(:email).of_type(:string) }
    it { should have_db_column(:phone).of_type(:string) }
    it { should have_db_column(:account_id).of_type(:integer) }
  end

  describe 'validation' do
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:account) }
    it { should allow_value('79889966886').for(:phone) }
    it { should_not allow_value('79889966').for(:phone) }
    it { should allow_value('test@test.rr').for(:email) }
    it { should_not allow_value('test@test.11').for(:email) }
    it { should validate_uniqueness_of(:phone).ignoring_case_sensitivity }
    it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
  end

  describe 'association' do
    it { should have_many(:templates).dependent(:destroy) }
    it { should have_many(:notes).dependent(:destroy) }
    it { should have_many(:membership_in_groups).dependent(:destroy) }
    it { should have_many(:groups).through(:membership_in_groups) }
    it { should belong_to(:account) }
  end

  describe 'callbacks' do
    describe 'before_save' do
      it 'updates account login' do
        expect { usr.update_attributes!(phone: '79889966886') }.to change { acc.reload.login }.to '79889966886'
      end
    end

    describe 'before_destroy' do
      let(:user1) { create :user }
      let(:user2) { create :user }
      let(:group) { create :group, notes: [create(:note, user: user1)] }
      before do
        create :group_relationship, user: user1, user_role: :owner, group: group
        create :group_relationship, user: user2, user_role: :editor, group: group
      end

      it 'deletes owned groups' do
        expect { user1.destroy }.to change { Group.count }.by(-1).
          and change { GroupRelationship.count }.by(-2)
      end
    end
  end

  describe '#login=' do
    context 'when argument is correct' do
      it 'assigns value to phone or email' do
        expect { usr.login = 'test@test.tt' }.to change { usr.email }.to('test@test.tt')
        expect { usr.login = '79889966886' }.to change { usr.phone }.to('79889966886')
      end
    end

    context 'when argument is invalid' do
      it 'raises error' do
        expect { usr.login = 'test' }.to raise_error(Errors::InvalidLoginError)
      end
    end
  end

  describe '#notes' do
    let(:user1) { create :user }
    let(:user2) { create :user }
    let(:group1) { create :group, notes: [create(:note, user: user2), create(:note, user: user2)] }

    before do
      create :group_relationship, user: user1, user_role: :editor, group: group1
      create :note, user: user1
    end

    it 'returns own notes and notes from user\'s groups' do
      expect(user1.notes.count).to eq 3
    end
  end

  describe '#owned_groups' do
    let(:user1) { create :user }
    let(:group1) { create :group }
    let(:group2) { create :group }
    let(:group3) { create :group }

    before do
      create :group_relationship, user: user1, user_role: :owner, group: group1
      create :group_relationship, user: user1, user_role: :owner, group: group2
      create :group_relationship, user: user1, user_role: :editor, group: group3
    end

    it 'returns own notes and notes from user\'s groups' do
      expect(user1.owned_groups.count).to eq 2
    end
  end
end
