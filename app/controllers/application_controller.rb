class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :require_login
  skip_before_action :require_login, if: proc { action_name == "index" && request.path_info == root_path } # see https://github.com/rails/rails/issues/9703

  rescue_from ActiveRecord::RecordNotFound do |_|
    render_errors(I18n.t('application.record_not_found'), 404)
  end

  def index
    render plain: "KEYK API v#{0}"
  end

  private

  def require_login
    render_errors(I18n.t('application.access_denied'), :unauthorized) unless current_account.present?
  end

  def current_account
    @current_account ||= authenticate_by_token
  end

  def current_user
    @current_user ||= current_account.user
  end

  # protected against timing attack
  def authenticate_by_token
    authenticate_with_http_token do |token, _opts|
      if (acc = Account.with_unexpired_token(token, 1.day.ago)).present?
        Current.token = acc.auth_tokens.find_by(value: token)

        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(token),
          ::Digest::SHA256.hexdigest(Current.token.value),
        )
        acc
      end
    end
  end

  # render json with errors and status
  # messages - Array or String
  def render_errors(messages, status)
    errors = { errors: [messages].flatten.map { |m| { message: m } } }
    render json: errors, status: status
  end
end
