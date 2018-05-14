class Account < ApplicationRecord
  has_secure_password

  validates :login, presence: true, uniqueness: true

  has_one :user, dependent: :destroy
  has_many :tokens, dependent: :destroy

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
      Token.where('value = :token and updated_at >= :date', token: token, date: date).first&.account
    end
  end

  def sign_out(token = nil)
    tokens.find_by(value: token)&.destroy!
  end
end
