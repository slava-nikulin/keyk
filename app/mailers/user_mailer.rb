class UserMailer < ApplicationMailer
  default from: 'system@yapm.ru'

  def confirm_email
    @account = Account.find(params[:account_id])
    mail(to: @account.login, subject: 'Welcome to YAPM')
  end
end
