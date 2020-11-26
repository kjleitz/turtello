class Users::ThreadsController < ApplicationController
  def show
    user = User.friendly.find(params[:user_id])
    buddy = User.friendly.find(params[:id])
    messages = user.messages_with(buddy)
    render json: MessageSerializer.new(messages).as_json
  end
end
