class MessageThreadsController < ApplicationController
  before_action :require_auth!

  def index
    user = User.friendly.find(params[:user_id])
    threads = policy_scope user.threads
    render json: MessageThreadSerializer.new(threads).as_json
  end

  def show
    user = User.friendly.find(params[:user_id])
    buddy = User.friendly.find(params[:id])
    thread = authorize MessageThread.find_or_initialize_for(user, buddy)
    render json: MessageThreadSerializer.new(thread).as_json
  end
end
