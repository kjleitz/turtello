require 'test_helper'

class UserBuddiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_buddy = user_buddies(:one)
  end

  test "should get index" do
    get user_buddies_url, as: :json
    assert_response :success
  end

  test "should create user_buddy" do
    assert_difference('UserBuddy.count') do
      post user_buddies_url, params: { user_buddy: { buddy_id: @user_buddy.buddy_id, user_id: @user_buddy.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show user_buddy" do
    get user_buddy_url(@user_buddy), as: :json
    assert_response :success
  end

  test "should update user_buddy" do
    patch user_buddy_url(@user_buddy), params: { user_buddy: { buddy_id: @user_buddy.buddy_id, user_id: @user_buddy.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy user_buddy" do
    assert_difference('UserBuddy.count', -1) do
      delete user_buddy_url(@user_buddy), as: :json
    end

    assert_response 204
  end
end
