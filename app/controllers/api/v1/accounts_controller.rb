module Api
  module V1
    class AccountsController < ApplicationController
      skip_before_action :require_login, only: :create, raise: false
      before_action only: :create do
        render_errors(I18n.t('application.invalid_params'), 500) if params[:account].blank?
      end

      def create
        service_call = RegisterUserService.new(registration_params.to_h).call
        if service_call.valid?
          @account = service_call.result[:account]
          @token = service_call.result[:token]
        else
          render_errors(service_call.errors.full_messages, 500)
        end
      end

      def destroy
        if current_account.destroy
          render json: { message: I18n.t('api.v1.accounts.destroyed') }
        else
          render_errors(current_account.errors.full_messages, 500)
        end
      end

      private

      def registration_params
        params.require(:account).permit(:login, :password)
      end
    end
  end
end
