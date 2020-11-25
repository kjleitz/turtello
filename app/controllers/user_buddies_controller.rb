class UserBuddiesController < ApplicationController
  before_action :require_auth!

  def index
    user_buddies = policy_scope UserBuddy.all
    render json: UserBuddySerializer.new(user_buddies).as_json
  end

  def show
    user_buddy = authorize UserBuddy.find(params[:id])
    render json: UserBuddySerializer.new(user_buddy).as_json
  end

  def create
    user_buddy = authorize UserBuddy.new(user_buddy_params)

    if user_buddy.save
      render status: :created, json: UserBuddySerializer.new(user_buddy).as_json
    else
      render_validation_failure(user_buddy)
    end
  end

  def update
    user_buddy = authorize UserBuddy.find(params[:id])

    if user_buddy.update(user_buddy_params)
      render json: UserBuddySerializer.new(user_buddy).as_json
    else
      render_validation_failure(user_buddy)
    end
  end

  def destroy
    user_buddy = authorize UserBuddy.find(params[:id])
    user_buddy.destroy
    render status: :no_content
  end

  private

  def user_buddy_params
    params.require(:user_buddy).permit(:user_id, :buddy_id)
  end
end
