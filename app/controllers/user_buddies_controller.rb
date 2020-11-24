class UserBuddiesController < ApplicationController
  # GET /user_buddies
  def index
    user_buddies = UserBuddy.all
    render json: user_buddies
  end

  # GET /user_buddies/1
  def show
    user_buddy = UserBuddy.find(params[:id])
    render json: user_buddy
  end

  # POST /user_buddies
  def create
    render status: :unauthorized and return unless user_buddy_params[:user_id] == current_user.id

    user_buddy = UserBuddy.new(user_buddy_params)

    if user_buddy.save
      render json: user_buddy, status: :created, location: user_buddy
    else
      render json: user_buddy.errors, status: :unprocessable_entity
    end
  end

  # PATCH /user_buddies/1
  # PUT /user_buddies/1
  def update
    user_buddy = UserBuddy.find(params[:id])

    if user_buddy.update(user_buddy_params)
      render json: user_buddy
    else
      render json: user_buddy.errors, status: :unprocessable_entity
    end
  end

  # DELETE /user_buddies/1
  def destroy
    user_buddy = UserBuddy.find(params[:id])
    user_buddy.destroy
  end

  private

  def user_buddy_params
    params.require(:user_buddy).permit(:user_id, :buddy_id)
  end
end
