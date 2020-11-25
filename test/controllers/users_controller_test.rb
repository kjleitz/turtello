require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:bob)
    @other_user = users(:david)
    @admin = users(:keegan)
  end

  test "should get index" do
    log_in_as(@user) do |auth_headers|
      get users_url, headers: auth_headers
      assert_response :success
      data = JSON.parse(response.body)['data']
      assert_not_equal(data.count, User.count)
    end

    log_in_as(@admin) do |auth_headers|
      get users_url, headers: auth_headers
      assert_response :success
      data = JSON.parse(response.body)['data']
      assert_equal(data.count, User.count)
    end
  end

  test "should create user" do
    params = { user: { username: 'blahblahman', password: 'jiminycricket' } }

    assert_difference('User.count') do
      post users_url, params: params
      assert_response 201
    end
  end

  test "should show user" do
    log_in_as(@user) do |auth_headers|
      get user_url(@user), headers: auth_headers
      assert_response :success
    end
  end

  test "should update user" do
    new_username = "#{@user.username}_abc"
    params = { user: { username: new_username } }
    patch user_url(@user), params: params
    assert_response :unauthorized
    assert_not_equal(@user.reload.username, new_username)

    log_in_as(@user) do |auth_headers|
      params = { user: { username: new_username } }
      patch user_url(@user), params: params, headers: auth_headers
      assert_response 200
      assert_equal(@user.reload.username, new_username)

      new_password = 'new_password_123'
      old_password_digest = @user.password_digest
      params = { user: { new_password: new_password } }
      patch user_url(@user), params: params, headers: auth_headers
      assert_response :unauthorized
      assert_equal(@user.reload.password_digest, old_password_digest)

      params = { user: { password: 'password', new_password: new_password } }
      patch user_url(@user), params: params, headers: auth_headers
      assert_response 200
      assert_not_equal(@user.reload.password_digest, old_password_digest)

      @user.password = 'password'
      @user.save!
    end

    log_in_as(@user) do |auth_headers|
      new_admin_username = "#{@admin.username}_abc"
      params = { user: { username: new_admin_username } }
      patch user_url(@admin), params: params, headers: auth_headers
      assert_response :forbidden
      assert_not_equal(@admin.reload.username, new_admin_username)
    end

    log_in_as(@admin) do |auth_headers|
      new_peasant_username = "#{@user.username}_abc"
      params = { user: { username: new_peasant_username } }
      patch user_url(@user), params: params, headers: auth_headers
      assert_response 200
      assert_equal(@user.reload.username, new_peasant_username)
    end
  end

  test "should destroy user" do
    log_in_as(@user) do |auth_headers|
      assert_no_difference('User.count') do
        delete user_url(@admin), headers: auth_headers
        assert_response :forbidden
      end
    end

    log_in_as(@user) do |auth_headers|
      assert_difference('User.count', -1) do
        delete user_url(@user), headers: auth_headers
        assert_response 204
      end
    end

    log_in_as(@admin) do |auth_headers|
      assert_difference('User.count', -1) do
        delete user_url(@other_user), headers: auth_headers
        assert_response 204
      end
    end
  end
end
