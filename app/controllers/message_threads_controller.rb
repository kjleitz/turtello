class MessageThreadsController < ApplicationController
  before_action :require_auth!

  def index
    threads = if params[:user_id]
      user = User.friendly.find(params[:user_id])
      policy_scope filter_scope user.threads
    else
      policy_scope filter_scope MessageThread.all
    end

    render json: MessageThreadSerializer.new(threads, include: serializer_include).as_json
  end

  def show
    thread = if params[:user_id]
      user = User.friendly.find(params[:user_id])
      buddy = User.friendly.find(params[:id])
      authorize MessageThread.find_or_initialize_for(user, buddy)
    else
      authorize MessageThread.friendly.find(params[:id])
    end

    render json: MessageThreadSerializer.new(thread, include: serializer_include).as_json
  end
end
