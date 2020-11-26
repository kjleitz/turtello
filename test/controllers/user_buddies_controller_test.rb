require 'test_helper'

class UserBuddiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_buddy = user_buddies(:bob_david)
    @user = @user_buddy.user
    @buddy = @user_buddy.buddy
    @admin = users(:keegan)
    @new_user = User.create(username: 'new_user', password: 'password')
  end

  test "should get index" do
    log_in_as(@user) do |auth_headers|
      get user_buddies_url, headers: auth_headers
      assert_response :success
      data = JSON.parse(response.body)['data']
      assert_not_equal(data.count, UserBuddy.count)
    end

    log_in_as(@admin) do |auth_headers|
      get user_buddies_url, headers: auth_headers
      assert_response :success
      data = JSON.parse(response.body)['data']
      assert_not_equal(data.count, UserBuddy.count)
    end
  end

  test "should create user_buddy" do
    brand_new_user = User.create(username: 'the_poopsmith', password: 'password')
    params = { user_buddy: { user_id: @user.id, buddy_id: brand_new_user.id } }

    assert_no_difference('UserBuddy.count') do
      post user_buddies_url, params: params
      assert_response :unauthorized
    end

    log_in_as(@user) do |auth_headers|
      assert_difference('UserBuddy.count', 1) do
        post user_buddies_url, params: params, headers: auth_headers
        assert_response :created
      end
    end

    params = { user_buddy: { user_id: @admin.id, buddy_id: brand_new_user.id } }

    log_in_as(brand_new_user) do |auth_headers|
      assert_no_difference('UserBuddy.count') do
        post user_buddies_url, params: params, headers: auth_headers
        assert_response :forbidden
      end
    end

    log_in_as(@admin) do |auth_headers|
      assert_difference('UserBuddy.count', 1) do
        post user_buddies_url, params: params, headers: auth_headers
        assert_response :created
      end
    end
  end

  test "should show user_buddy" do
    user_buddy = @user.user_buddies.first

    log_in_as(@user) do |auth_headers|
      get user_buddy_url(user_buddy), headers: auth_headers
      assert_response :success
    end

    user_stalker = @user.user_stalkers.first

    log_in_as(@user) do |auth_headers|
      get user_buddy_url(user_stalker), headers: auth_headers
      assert_response :success
    end

    user_buddy = @user.user_buddies.first

    log_in_as(@new_user) do |auth_headers|
      get user_buddy_url(user_buddy), headers: auth_headers
      assert_response :forbidden
    end

    log_in_as(@admin) do |auth_headers|
      get user_buddy_url(user_buddy), headers: auth_headers
      assert_response :success
    end
  end

  test "should update user_buddy" do
    # TODO: change the modified field to one that would _actually_ be changed,
    #       once more fields are added
    brand_new_user = User.create(username: 'the_poopsmith', password: 'password')
    params = { user_buddy: { user_id: @user.id, buddy_id: brand_new_user.id } }
    user_buddy = @user.user_buddies.first
    old_buddy_id = user_buddy.buddy_id

    patch user_buddy_url(user_buddy), params: params
    assert_response :unauthorized
    assert_equal(user_buddy.reload.buddy.id, old_buddy_id)

    log_in_as(@user) do |auth_headers|
      patch user_buddy_url(user_buddy), params: params, headers: auth_headers
      assert_response :success
      assert_equal(user_buddy.reload.buddy.id, brand_new_user.id)
    end

    extra_brand_new_user = User.create(username: 'coach', password: 'password')
    params = { user_buddy: { user_id: @user.id, buddy_id: extra_brand_new_user.id } }
    user_buddy = @user.user_buddies.first
    old_buddy_id = user_buddy.buddy_id

    log_in_as(extra_brand_new_user) do |auth_headers|
      patch user_buddy_url(user_buddy), params: params, headers: auth_headers
      assert_response :forbidden
      assert_equal(user_buddy.reload.buddy.id, old_buddy_id)
    end

    log_in_as(@admin) do |auth_headers|
      patch user_buddy_url(user_buddy), params: params, headers: auth_headers
      assert_response :success
      assert_equal(user_buddy.reload.buddy.id, extra_brand_new_user.id)
    end
  end

  test "should destroy user_buddy" do
    assert_no_difference('UserBuddy.count') do
      delete user_buddy_url(@user_buddy)
      assert_response :unauthorized
    end

    log_in_as(@user) do |auth_headers|
      assert_difference('UserBuddy.count', -1) do
        delete user_buddy_url(@user_buddy), headers: auth_headers
        assert_response 204
      end
    end

    admin_user_buddy = @admin.user_buddies.first

    log_in_as(@user) do |auth_headers|
      assert_no_difference('UserBuddy.count') do
        delete user_buddy_url(admin_user_buddy), headers: auth_headers
        assert_response :forbidden
      end
    end

    log_in_as(@admin) do |auth_headers|
      assert_difference('UserBuddy.count', -1) do
        delete user_buddy_url(admin_user_buddy), headers: auth_headers
        assert_response 204
      end
    end

    peasant_user_buddy = @user.user_buddies.first

    log_in_as(@admin) do |auth_headers|
      assert_difference('UserBuddy.count', -1) do
        delete user_buddy_url(peasant_user_buddy), headers: auth_headers
        assert_response 204
      end
    end
  end
end
