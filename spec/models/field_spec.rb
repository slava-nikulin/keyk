RSpec.describe Field, type: :model do
  subject { build(:field) }

  before do
    salt = (0..64).map { |_| rand(0...255) }.pack('C64') # 64-bytes string
    allow(Rails.application.credentials).to receive(:dig).with(:security, :salt).and_return(salt)
    allow(Rails.application.credentials).to receive(:dig).with(:security, :key_size).and_return(32)
    allow(Rails.application.credentials).to receive(:dig).with(:security, :secret_key).and_return('a' * 32)
  end

  describe 'db' do
    it { should have_db_column(:title).of_type(:string) }
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:input_type).of_type(:integer) }
    it { should have_db_column(:order).of_type(:integer) }
    it { should have_db_column(:value).of_type(:string) }
    it { should have_db_column(:note_id).of_type(:integer) }
  end

  describe 'validation' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:value) }
    it { should validate_presence_of(:note) }
    it { should validate_uniqueness_of(:name).scoped_to(:note_id) }
  end

  describe 'association' do
    it { should belong_to(:note) }
  end

  describe 'enum' do
    it { should define_enum_for(:input_type).with(%i(text email password)) }
  end

  describe 'encrypted/decrypted value' do
    let(:field) { create :field, value: 'test' }

    context 'when field is saved in db' do
      it 'model returns decrypted value, but db stores encrypted one' do
        expect(field.reload.value).to eq('test')
        encrypted_value = ActiveRecord::Base.connection.execute('select value from fields limit 1').to_a.first['value']
        expect(encrypted_value).not_to eq('test')
      end
    end

    context 'when value was updated' do
      before { field.update_attributes(value: 'new_val') }

      it 'saves and returns value correctly' do
        expect(field.reload.value).to eq 'new_val'
      end
    end

    context 'when field was initialized, but was not saved' do
      let(:new_field) { build :field, value: 'test1' }
      it 'returns correct value' do
        expect(new_field.value).to eq 'test1'
        new_field.save
        expect(new_field.reload.value).to eq 'test1'
      end
    end
  end
end
