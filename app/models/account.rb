class Account < ApplicationRecord
  has_secure_password

  validates :login, presence: true, uniqueness: true

  has_one :user, dependent: :destroy
  has_many :auth_tokens, dependent: :destroy
  has_one :confirm_token, dependent: :destroy
  has_one :reset_token, dependent: :destroy

  class << self
    def valid_login?(login, password)
      Account.find_by(login: login)&.authenticate(password)
    end

    def login_key(str)
      if str.match? Constants::PHONE_REGEX
        :phone
      elsif str.match? Constants::EMAIL_REGEX
        :email
      else
        raise Errors::InvalidLoginError
      end
    end

    def with_unexpired_token(token, date)
      Account.joins(:auth_tokens).where(
        'tokens.value = :token AND tokens.updated_at >= :date AND accounts.confirmed_at IS NOT NULL', token: token, date: 1.day.ago
      ).first
    end
  end

  def email_as_login?
    Account.login_key(login) == :email
  end

  def sign_out(token = nil)
    auth_tokens.find_by(value: token)&.destroy!
  end
end
