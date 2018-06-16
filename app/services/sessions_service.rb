# Authorizes user with token.
# params - Hash, required
# login - email or phone
# password
class SessionsService < BaseService
  def initialize(params = {})
    @session_params = params
    super
  end

  def call
    begin
      if acc = Account.valid_login?(@session_params[:login], @session_params[:password])
        result[:token] = acc.tokens.create.value
      else
        errors.add(:base, :authorize_error, message: I18n.t('application.authorize_error'))
      end
    rescue => e
      errors.add(:base, :sign_in_user, message: e.message)
    end
    self
  end
end
