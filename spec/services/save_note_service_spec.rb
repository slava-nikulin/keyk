RSpec.describe SaveNoteService do
  let(:user) { create :user }

  context '#call' do
    context 'creation' do
      let(:valid_params) do
        {
          title: 'test_note',
          fields_attributes: [
            { title: 'Email', input_type: 'email', order: 1, name: 'email', value: 'test@test.rr' },
            { title: 'password', input_type: 'password', order: 2, name: 'password', value: 'password' }
          ]
        }
      end

      it 'creates new template' do
        res = {}
        expect { res = described_class.new(user: user, params: valid_params).call }.
          to change { Note.count }.by(1).
          and change { user.notes.count }.by(1)

        expect(res.valid?).to be_truthy
      end
    end

    context 'when config is invalid' do
      let(:invalid_params) { { title: nil } }

      it 'returns corresponding error message' do
        res = {}
        expect { res = described_class.new(user: user, params: invalid_params).call }.
          to change { Note.count }.by(0).
          and change { user.notes.count }.by(0)
        expect(res.errors.count).to eq 1

        expect(res.valid?).to be_falsey
      end
    end

    context 'when arguments are empty' do
      it 'returns corresponding error' do
        res = described_class.new(user: nil, params: nil).call
        expect(res.errors.count).to eq 1
      end
    end

    context 'update' do
      context 'when parameters are valid' do
        let(:note) { create(:note, user: user) }
        let(:valid_params) do
          {
            user: user,
            note_id: note.id,
            params: {
              title: 'note2'
            }
          }
        end

        it 'updates user\'s note' do
          res = {}

          expect { res = described_class.new(valid_params).call }.
            to change { note.reload.title }.to('note2')

          expect(res.valid?).to be_truthy
        end
      end

      context 'when user is not able to edit note' do
        let(:outside_note) { create :note, user: create(:user) }
        let(:valid_params) do
          {
            user: user,
            note_id: outside_note.id,
            params: {
              title: 'new_title'
            }
          }
        end

        it 'returns error' do
          res = described_class.new(valid_params).call
          expect(res.valid?).to be_falsey
          expect(res.errors.full_messages.to_sentence).to eq 'Operation is unauthorized'
        end

        context 'when user is in notes group as editor' do
          before do
            create(
              :group_relationship,
              group: create(:group, notes: [outside_note]),
              user_role: :editor,
              user: user,
            )
          end

          it 'updates user\'s note' do
            res = {}
            expect { res = described_class.new(valid_params).call }.
              to change { outside_note.reload.title }.to('new_title')

            expect(res.valid?).to be_truthy
          end
        end
      end
    end
  end
end
