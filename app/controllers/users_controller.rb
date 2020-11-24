class UsersController < ApplicationController
  before_action :require_auth!, except: [:create]

  # GET /users
  def index
    users = User.all
    render json: users
  end

  # GET /users/1
  def show
    user = User.find(params[:id])
    render json: @user
  end

  # POST /users
  def create
    user = User.new(user_create_params)

    if user.save
      set_current_user!(user)
      render json: user, status: :created, location: user
    else
      render_validation_failure(user)
    end
  end

  # PATCH /users/1
  # PUT /users/1
  def update
    user = User.find(params[:id])
    render status: :unauthorized and return unless user.authenticate(current_password)

    if user.update(user_update_params)
      render json: user
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    user = User.find(params[:id])
    user.destroy
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
    new_password = user_params[:new_password]
    base_params = user_params.except(:new_password)
    new_password.present? ? base_params.merge(password: new_password) : base_params
  end

  def current_password
    user_params[:password]
  end
end
