RSpec.describe Template, type: :model do
  before do
    salt = (0..64).map { |_| rand(0...255) }.pack('C64') # 64-bytes string
    allow(Rails.application.credentials).to receive(:dig).with(:security, :salt).and_return(salt)
    allow(Rails.application.credentials).to receive(:dig).with(:security, :key_size).and_return(32)
    allow(Rails.application.credentials).to receive(:dig).with(:security, :secret_key).and_return('a' * 32)
  end

  describe 'validation' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:config) }
    it { should validate_uniqueness_of(:title) }
  end

  describe 'association' do
    it { should belong_to(:user) }
    it { should have_many(:notes).dependent(:destroy) }
  end

  describe '#create_note' do
    let(:template) { create :template }
    let(:note_params) { { title: 'test note', values: { email: 'test@test.com', password: '123123' } } }

    it 'creates note with fields by given params' do
      expect { template.create_note(note_params) }.to change { Note.count }.by(1)
      note = Note.last
      expect(note.fields.count).to eq 2
      password_field = note.fields.last
      expect(password_field.input_type).to eq 'password'
      expect(password_field.value).to eq '123123'
    end
  end
end
