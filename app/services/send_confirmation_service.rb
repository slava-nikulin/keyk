# Sends confirmation info by email or phone, depending the type of login
# id - account id
class SendConfirmationService < BaseService
  def initialize(id)
    @account = Account.find_by(id: id)
    super
  end

  def call
    if @account.blank?
      errors.add(:base, :empty_account, message: I18n.t('application.invalid_params'))
    else
      begin
        result[:confirm_type] = @account.email_as_login? ? send_email : send_sms
      rescue => e
        errors.add(:base, :send_confirm, message: e.message)
      end
    end
    self
  end

  private

  def send_email
    @account.create_confirm_token!
    UserMailer.with(account_id: @account.id).confirm_email.deliver_later
    :email
  end

  # TODO: implement
  def send_sms
    :sms
    raise NotImplementedError
  end

  def phone_token
    prng = Random.new(10)
    (1..6).each_with_object('') { |_, res| res << prng.rand(10).to_s }
  end
end
