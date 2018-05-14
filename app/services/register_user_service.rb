# Registers account with user or returns errors
# params - Hash, required
# login - email or phone
# password
class RegisterUserService < BaseService
  def initialize(params = {})
    @registration_params = params
    @result = {}
    super
  end

  def call
    ActiveRecord::Base.transaction do
      begin
        acc = Account.new(login: @registration_params[:login], password: @registration_params[:password])
        acc.build_user(login: @registration_params[:login])
        acc.save!
        token = acc.tokens.create!
        result[:account] = acc
        result[:token] = token
      rescue Errors::InvalidLoginError
        errors.add(:base, :invalid_login, message: I18n.t('application.authorize_error'))
        raise ActiveRecord::Rollback
      rescue => e
        errors.add(:base, :create_user, message: e.message)
        raise ActiveRecord::Rollback
      end
    end
    self
  end
end
