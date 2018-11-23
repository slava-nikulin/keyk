# Registers account with user or returns errors
# params - Hash, required
# login - email or phone
# password
class RegisterUserService < BaseService
  def initialize(params = {})
    @reg_params = params
    super
  end

  def call
    ActiveRecord::Base.transaction do
      begin
        acc = Account.find_or_initialize_by(login: @reg_params[:login])
        raise Errors::DuplicateLoginError unless login_available?(acc)

        acc.assign_attributes(password: @reg_params[:password])
        acc.build_user(login: @reg_params[:login]) if acc.user.blank?

        acc.save! if acc.changed?

        result[:account] = acc
      rescue Errors::DuplicateLoginError
        errors.add(:base, :duplicate_login, message: I18n.t('application.duplicate_login'))
        raise ActiveRecord::Rollback
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

  private

  def login_available?(acc)
    acc.confirmed_at.blank? && (acc.confirm_token&.updated_at.blank? || acc.confirm_token.updated_at < 1.day.ago)
  end
end
