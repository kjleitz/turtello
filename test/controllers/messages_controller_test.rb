require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @message = messages(:thread_1_message_1)
    @sender = @message.sender
    @admin = users(:keegan)
    admin_message_receiver = User.where.not(id: [@sender.id, @admin.id]).first
    @admin_message = @admin.sent_messages.create(receiver: admin_message_receiver, body: "hello")
  end

  test "should get index" do
    log_in_as(@sender) do |auth_headers|
      get messages_url, headers: auth_headers
      assert_response :success
      data = JSON.parse(response.body)['data']
      assert_not_equal(data.count, Message.count)
    end

    log_in_as(@admin) do |auth_headers|
      get messages_url, headers: auth_headers
      assert_response :success
      data = JSON.parse(response.body)['data']
      assert_not_equal(data.count, Message.count)
    end
  end

  test "should create message" do
    log_in_as(@sender) do |auth_headers|
      valid_params = {
        message: {
          sender_id: @sender.id,
          receiver_id: @sender.buddies.first.id,
          body: "hey, this is me!",
        }
      }

      assert_difference('Message.count') do
        post messages_url, params: valid_params, headers: auth_headers
        assert_response 201
      end

      invalid_params = {
        message: {
          sender_id: @admin.id,
          receiver_id: @admin.buddies.first.id,
          body: "whoa, that's not me!"
        }
      }

      assert_no_difference('Message.count') do
        post messages_url, params: invalid_params, headers: auth_headers
        assert_response :forbidden
      end
    end

    log_in_as(@admin) do |auth_headers|
      valid_params = {
        message: {
          sender_id: @admin.id,
          receiver_id: @admin.buddies.first.id,
          body: "hey, this is me!",
        }
      }

      assert_difference('Message.count') do
        post messages_url, params: valid_params, headers: auth_headers
        assert_response 201
      end

      invalid_params = {
        message: {
          sender_id: @sender.id,
          receiver_id: @sender.buddies.first.id,
          body: "whoa, that's not me!"
        }
      }

      assert_no_difference('Message.count') do
        post messages_url, params: invalid_params, headers: auth_headers
        assert_response :forbidden
      end
    end
  end

  test "should show message" do
    get message_url(@message)
    assert_response :unauthorized

    log_in_as(@sender) do |auth_headers|
      get message_url(@message), headers: auth_headers
      assert_response :success
    end

    log_in_as(@admin) do |auth_headers|
      get message_url(@message), headers: auth_headers
      assert_response :success
    end

    log_in_as(@sender) do |auth_headers|
      get message_url(@admin_message), headers: auth_headers
      assert_response :forbidden
    end

    log_in_as(@admin) do |auth_headers|
      get message_url(@admin_message), headers: auth_headers
      assert_response :success
    end
  end

  test "should update message" do
    new_body = "#{@message.body}... PS: wait nvm i forgot"
    params = {
      message: {
        body: new_body,
        receiver_id: @message.receiver_id,
        sender_id: @message.sender_id
      }
    }

    patch message_url(@message), params: params
    assert_response :unauthorized
    assert_not_equal(@message.reload.body, new_body)

    log_in_as(@sender) do |auth_headers|
      patch message_url(@message), params: params, headers: auth_headers
      assert_response :success
      assert_equal(@message.reload.body, new_body)
    end

    new_body = "#{@message.body}... PS: wait nvm i forgot (edited)"
    params = {
      message: {
        body: new_body,
        receiver_id: @message.receiver_id,
        sender_id: @message.sender_id
      }
    }

    log_in_as(@admin) do |auth_headers|
      patch message_url(@message), params: params, headers: auth_headers
      assert_response :success
      assert_equal(@message.reload.body, new_body)
    end

    new_body = "#{@admin_message.body}... PS: wait nvm i forgot"
    params = {
      message: {
        body: new_body,
        receiver_id: @admin_message.receiver_id,
        sender_id: @admin_message.sender_id
      }
    }

    patch message_url(@admin_message), params: params
    assert_response :unauthorized
    assert_not_equal(@admin_message.reload.body, new_body)

    log_in_as(@sender) do |auth_headers|
      patch message_url(@admin_message), params: params, headers: auth_headers
      assert_response :forbidden
      assert_not_equal(@admin_message.reload.body, new_body)
    end

    log_in_as(@admin) do |auth_headers|
      patch message_url(@admin_message), params: params, headers: auth_headers
      assert_response :success
      assert_equal(@admin_message.reload.body, new_body)
    end
  end

  test "should destroy message" do
    assert_no_difference('Message.count') do
      delete message_url(@message)
      assert_response :unauthorized
    end

    log_in_as(@sender) do |auth_headers|
      assert_no_difference('Message.count') do
        delete message_url(@admin_message), headers: auth_headers
        assert_response :forbidden
      end
    end

    log_in_as(@sender) do |auth_headers|
      assert_difference('Message.count', -1) do
        delete message_url(@message), headers: auth_headers
        assert_response :success
      end
    end

    log_in_as(@admin) do |auth_headers|
      assert_difference('Message.count', -1) do
        delete message_url(@admin_message), headers: auth_headers
        assert_response :success
      end
    end

    peasant_message = @sender.sent_messages.create(receiver: @sender.buddies.first, body: "sup")

    log_in_as(@admin) do |auth_headers|
      assert_difference('Message.count', -1) do
        delete message_url(peasant_message), headers: auth_headers
        assert_response 204
      end
    end
  end
end
