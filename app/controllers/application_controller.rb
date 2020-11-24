class ApplicationController < ActionController::API
  include ActionController::Cookies

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  ERROR_CODES = {
    validation_failure: "Model failed validation.",
    not_found: "Resource not found.",
    auth_token_invalid: "Auth token is expired, invalid, or missing. A valid token must be included in the headers of the request, like 'Authorization: Bearer <token>'. A new token may be obtained via re-authentication or the token refresh endpoint.",
    refresh_token_invalid: "Refresh token is expired, invalid, or missing. A new token must be obtained via re-authentication."
  }.freeze

  def set_current_user!(user)
    reset_session # to prevent session fixation attacks
    set_auth_claims!(user)
    set_new_refresh!(user)
    @current_user = user
  end

  def unset_current_user!
    reset_session
    unset_auth_claims!
    unset_refresh!
    @current_user = nil
  end

  def refresh_current_user!
    user = User.find_by(id: user_id_for_refresh) if can_refresh?

    if user.present?
      set_current_user!(user)
      user
    else
      unset_current_user!
      nil
    end
  end

  def current_user
    return @current_user if defined?(@current_user)

    user = User.find_by(id: user_id_from_auth_token) if user_id_from_auth_token.present?
    unset_current_user! if user.blank?
    @current_user = user
  end

  def logged_in?
    current_user.present?
  end

  def authenticated?
    logged_in?
  end

  def logged_out?
    !logged_in?
  end

  def log_in_user!(username:, password:)
    user = User.find_by(username: username)&.authenticate(password)
    if user.present?
      set_current_user!(user)
      user
    else
      unset_current_user!
      nil
    end
  end

  def log_out_user!
    unset_current_user!
    nil
  end

  def json_error(code, message: nil, messages: nil)
    error_code = code.to_sym

    unless ERROR_CODES.has_key?(error_code)
      raise ArgumentError, "Code `#{error_code.inspect}` is not described in `ApplicationController::ERROR_CODES`"
    end

    error_messages = [message, *(messages || [])].compact

    {
      error: {
        code: error_code,
        description: ERROR_CODES[error_code],
        messages: error_messages.presence || ["Something went wrong"]
      }
    }
  end

  def render_validation_failure(model_record)
    json_body = json_error(:validation_failure, messages: model_record.errors.full_messages)
    render status: :unprocessable_entity, json: json_body
  end

  def render_404
    render status: :not_found, json: json_error(:not_found)
  end

  def require_auth!
    unless authenticated?
      render status: :unauthorized, json: json_error(:auth_token_invalid)
    end
  end

  private

  def refresh_expires_at
    refresh_expires_at, user_id = session.values_at(:refresh_expires_at, :user_id)
    if refresh_expires_at.present? && user_id.present?
      Time.zone.at(refresh_expires_at)
    else
      Time.zone.now
    end
  end

  def can_refresh?
    refresh_expires_at.future?
  end

  def refresh_expired?
    !can_refresh?
  end

  def set_new_refresh!(user)
    raise ArgumentError, "Invalid user: `#{user.inspect}`" unless user.is_a?(User) && user.persisted?
    session[:user_id] = user.id
    session[:refresh_expires_at] = 30.days.from_now.to_i
  end

  def unset_refresh!
    session[:user_id] = nil
    session[:refresh_expires_at] = nil
  end

  def set_auth_claims!(user)
    raise ArgumentError, "Invalid user: `#{user.inspect}`" unless user.is_a?(User) && user.persisted?
    @auth_claims = { user_id: user.id }
    auth_token = JwtToken.encode(@auth_claims)
    response.set_header('Authorization', "Bearer #{auth_token}")
  end

  def unset_auth_claims!
    @auth_claims = {}
    auth_token = JwtToken.encode(@auth_claims)
    response.set_header('Authorization', "Bearer #{auth_token}")
  end

  def auth_claims
    @auth_claims ||= begin
      auth_header = request.headers['Authorization'].presence || ''
      auth_token = auth_header.gsub(/\Abearer +/i, '').strip
      JwtToken.decode(auth_token) || {}
    end
  end

  def user_id_from_auth_token
    auth_claims[:user_id].presence
  end

  def user_id_for_refresh
    session[:user_id].presence if can_refresh?
  end
end
