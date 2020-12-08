class MessagesController < ApplicationController
  before_action :require_auth!

  def index
    messages = policy_scope filter_scope Message.all
    render json: MessageSerializer.new(messages, include: serializer_include).as_json
  end

  def show
    message = authorize Message.find(params[:id])
    render json: MessageSerializer.new(message, include: serializer_include).as_json
  end

  def create
    message = authorize Message.new(message_params)

    if message.save
      render status: :created, json: MessageSerializer.new(message, include: serializer_include).as_json
    else
      render_validation_failure(message)
    end
  end

  def update
    message = authorize Message.find(params[:id])

    if message.update(message_params)
      render json: MessageSerializer.new(message, include: serializer_include).as_json
    else
      render_validation_failure(message)
    end
  end

  def destroy
    message = authorize Message.find(params[:id])
    message.destroy
    render status: :no_content
  end

  private

  def message_params
    params.require(:message).permit(:sender_id, :receiver_id, :body)
  end
end
