class SessionsController < ApplicationController
  def create
    username, password = session_params.values_at(:username, :password)
    user = log_in_user!(username: username, password: password)
    if user.present?
      render json: user
    else
      render status: :unauthorized, json: { errors: ["Incorrect username/password combination"] }
    end
  end

  def destroy
    log_out_user!
    render status: :no_content
  end

  def refresh
    user = refresh_current_user!
    if user.present?
      render json: user
    else
      render status: :unauthorized, json: { errors: ["Authentication expired"] }
    end
  end

  private

  def session_params
    params.require(:user).permit(:username, :password)
  end
end
