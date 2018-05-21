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
  end
end
