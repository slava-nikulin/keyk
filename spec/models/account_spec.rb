RSpec.describe Account, type: :model do
  subject(:acc) { create(:account, :with_user, login: '79889966886') }

  describe 'db' do
    it { should have_db_column(:password_digest).of_type(:string) }
    it { should have_db_column(:login).of_type(:string) }

    it { should have_db_column(:confirmed_at).of_type(:datetime) }

    it { should have_db_column(:failed_attempts).of_type(:integer) }
  end

  describe 'associations' do
    it { should have_one(:user).dependent(:destroy) }
    it { should have_many(:auth_tokens).dependent(:destroy) }
    it { should have_one(:confirm_token).dependent(:destroy) }
    it { should have_one(:reset_token).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:login) }
    it { should validate_uniqueness_of(:login).ignoring_case_sensitivity }
  end

  describe '#sign_out' do
    it 'deletes token' do
      expect { acc.sign_out(acc.auth_tokens.last.value) }.to change { acc.auth_tokens.count }.by(-1)
    end
  end

  describe '#login' do
    it 'returns user\'s login' do
      expect(acc.login).to eq acc.user.phone
    end
  end

  describe 'class_methods' do
    describe '#valid_login?' do
      before { create :account, :with_user, login: 'test@test.rr', password: 'password' }

      it 'returns false, when credentials are invalid' do
        expect(described_class.valid_login?('test@test.rr', '123')).to be_falsey
      end

      it 'returns true, when credentials are valid' do
        expect(described_class.valid_login?('test@test.rr', 'password')).to be_truthy
      end
    end

    describe '#login_key' do
      let(:email) { 'test@test.rr' }
      let(:phone) { '79889966886' }

      it 'returns corresponding key, when valid data was passed' do
        expect(described_class.login_key(phone)).to eq :phone
        expect(described_class.login_key(email)).to eq :email
      end

      it 'raises ArgumentError when passed data is invalid' do
        expect { described_class.login_key('test') }.to raise_error(Errors::InvalidLoginError)
      end
    end

    describe '#with_unexpired_token' do
      let!(:account) { create :account, :confirmed }
      let!(:token) { account.auth_tokens.last }

      context 'when token is expired' do
        before { token.update_attributes!(updated_at: Time.zone.now - 100.days) }

        it 'returns nil' do
          expect(described_class.with_unexpired_token(token.value, 1.day.ago)).to be_nil
        end
      end

      context 'when token is actual' do
        it 'returns account' do
          expect(described_class.with_unexpired_token(token.value, 1.day.ago)).to eq account
        end
      end
    end
  end
end
