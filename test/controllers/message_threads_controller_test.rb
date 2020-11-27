require 'test_helper'

class MessageThreadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:bob)
    @buddy = users(:david)
    @admin = users(:keegan)
    @new_user = User.create(username: 'new_user', password: 'password')
  end

  test "should get message thread index" do
    get user_message_threads_url(@user)
    assert_response :unauthorized

    log_in_as(@new_user) do |auth_headers|
      get user_message_threads_url(@user), headers: auth_headers
      assert_response :success
      data = JSON.parse(response.body)['data']
      assert_equal(data.count, 0)
    end

    log_in_as(@buddy) do |auth_headers|
      get user_message_threads_url(@user), headers: auth_headers
      assert_response :success
      data = JSON.parse(response.body)['data']
      assert_equal(data.count, 1)
    end

    log_in_as(@admin) do |auth_headers|
      get user_message_threads_url(@user), headers: auth_headers
      assert_response :success
      data = JSON.parse(response.body)['data']
      assert_equal(data.count, 1)
    end

    log_in_as(@user) do |auth_headers|
      get user_message_threads_url(@user), headers: auth_headers
      assert_response :success
      data = JSON.parse(response.body)['data']
      assert_equal(data.count, @user.message_threads.count)
    end
  end

  test "should show message thread" do
    get user_message_thread_url(@user, @buddy)
    assert_response :unauthorized

    log_in_as(@new_user) do |auth_headers|
      get user_message_thread_url(@user, @buddy), headers: auth_headers
      assert_response :forbidden
    end

    log_in_as(@buddy) do |auth_headers|
      get user_message_thread_url(@user, @buddy), headers: auth_headers
      assert_response :success
    end

    log_in_as(@user) do |auth_headers|
      get user_message_thread_url(@user, @buddy), headers: auth_headers
      assert_response :success
    end

    log_in_as(@admin) do |auth_headers|
      get user_message_thread_url(@user, @buddy), headers: auth_headers
      assert_response :success
    end
  end
end
