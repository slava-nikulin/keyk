module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :require_login, only: :create, raise: false

      def create
        service_call = SessionsService.new(session_params.to_h).call
        if service_call.valid?
          render json: { token: service_call.result[:token] }
        else
          render_errors(service_call.errors.full_messages, 500)
        end
      end

      def sign_out
        current_account.sign_out(Current.token.value)
        head :ok
      end

      private

      def session_params
        params.require(:account).permit(:login, :password)
      end
    end
  end
end
