class UsersController < ApplicationController
  before_action :require_auth!, except: [:create]

  def index
    users = policy_scope User.all
    render json: UserSerializer.new(users).as_json
  end

  def show
    user = authorize User.friendly.find(params[:id])
    render json: UserSerializer.new(user).as_json
  end

  def create
    user = authorize User.new(user_create_params)

    if user.save
      set_current_user!(user)
      render status: :created, json: UserSerializer.new(user).as_json
    else
      render_validation_failure(user)
    end
  end

  def update
    user = authorize User.friendly.find(params[:id])

    if new_password.present? && !user.authenticate(current_password)
      render status: :unauthorized, json: json_error(:credentials_invalid) and return
    end

    if user.update(user_update_params)
      render json: UserSerializer.new(user).as_json
    else
      render_validation_failure(user)
    end
  end

  def destroy
    user = authorize User.friendly.find(params[:id])
    user.destroy
    render status: :no_content
  end

  private

  def user_params
    params.require(:user).permit(
      :username,
      :password,
      :new_password
    )
  end

  def user_create_params
    user_params.except(:new_password)
  end

  def user_update_params
    base_params = user_params.except(:password, :new_password)
    new_password.present? ? base_params.merge(password: new_password) : base_params
  end

  def current_password
    user_params[:password]
  end

  def new_password
    user_params[:new_password]
  end
end
