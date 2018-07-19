RSpec.describe SaveGroupService do
  let(:group_owner) { create :user }
  let(:user1) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }
  let(:note1) { create :note }
  let(:note2) { create :note }
  let(:note3) { create :note }
  let(:group) { create(:group, notes: [note1, note2, note3], guests: [user1, user2, user3], owners: [group_owner]) }
  let(:valid_params) do
    {
      owner: group_owner,
      group_params: { title: 'Test group' },
      members_params: {
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
      },
      group_id: nil,
    }
  end

  context 'when params are valid' do
    context 'when group is new' do
      it 'creates new group' do
        res = {}
        res = described_class.new(valid_params).call
        expect { res = described_class.new(valid_params).call }.to change { Group.count }.by(1)
        expect(res.result[:group]).to be_present
        expect(res.result[:group].notes.count).to eq 2
        expect(res.result[:group].users.count).to eq 2
        expect(res.valid?).to be_truthy
      end
    end

    context 'when group exists' do
      before { valid_params[:group_id] = group.id }

      it 'updates group' do
        res = {}
        expect { res = described_class.new(valid_params).call }.to change { group.guests.count }.by(-1).
          and change { group.notes.count }.by(-1)
        expect(res.result[:group]).to eq group.reload
        expect(res.valid?).to be_truthy
      end
    end
  end

  context 'when params are invalid' do
    context 'when group is new' do
      context 'when group validation failed' do
        let(:invalid_params) do
          valid_params[:group_params] = {}
          valid_params
        end

        it 'returns errors' do
          res = {}
          expect { res = described_class.new(invalid_params).call }.to change { Group.count }.by(0)
          expect(res.errors.full_messages.to_sentence).to include 'can\'t be blank'
          expect(res.valid?).to be_falsey
        end
      end
    end

    context 'when group is being updating' do
      context 'when user is not owner' do
        before { valid_params[:group_id] = group.id }

        let(:invalid_params) do
          valid_params[:owner] = user1
          valid_params
        end

        it 'returns errors' do
          res = {}
          res = described_class.new(invalid_params).call
          expect { res = described_class.new(invalid_params).call }.to change { Group.count }.by(0)
          expect(res.errors.full_messages.to_sentence).to eq 'Operation is unauthorized'
          expect(res.valid?).to be_falsey
        end
      end
    end
  end
end
