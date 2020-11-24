class ApplicationController < ActionController::API
  def set_current_user(user)
    session[:refresh_expires_at] = 30.days.from_now.to_i
    token = JwtToken.encode({ user_id: user.id })
    response.set_header('Authorization', "Bearer #{token}")
  end

  def can_refresh_token?
    return false if session[:refresh_expires_at].blank?
    Time.zone.now < Time.zone.at(session[:refresh_expires_at])
  end

  def current_user
    @current_user = if defined?(@current_user)
      @current_user
    else
      authorization = request.headers['Authorization'].presence || ''
      token = authorization.gsub(/\Abearer +/i, '')
      claims = JwtToken.decode(token) || {}
      User.find_by(id: claims[:user_id])
    end
  end
end
