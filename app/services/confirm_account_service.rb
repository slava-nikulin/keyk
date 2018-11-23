# Confirms user email
# params - Hash, required
# login - email or phone
# confirm_token
class ConfirmAccountService < BaseService
  def initialize(params = {})
    @confirm_params = params
    super
  end

  def call
    begin
      acc = Account.joins(:confirm_token)
        .where(
          "accounts.login = :login and tokens.value = :token and tokens.updated_at > (NOW() - INTERVAL '1 DAY')",
          login: @confirm_params[:login], token: @confirm_params[:confirm_token]
        )
        .first

      if acc.present?
        acc.update_attributes!(confirmed_at: Time.zone.now)
      else
        raise Errors::ConfirmationFailed
      end

      token = acc.auth_tokens.create!
      result[:account] = acc
      result[:token] = token.value
    rescue Errors::ConfirmationFailed
      errors.add(:base, :confirmation_failed, message: I18n.t('application.confirmation_failed'))
    rescue => e
      errors.add(:base, :create_user, message: e.message)
    end

    self
  end
end
