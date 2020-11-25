require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:bob)
  end

  test "should create session" do
    get user_url(@user)
    assert_response :unauthorized

    params = { user: { username: @user.username, password: 'password' } }
    post sign_in_url, params: params
    assert_response 200
    auth_header = response.headers['Authorization']
    assert_not_empty(auth_header)
    assert_match(/\Abearer +\S+/i, auth_header)

    get user_url(@user), headers: { Authorization: auth_header }
    assert_response 200
  end

  test "should destroy session" do
    get user_url(@user)
    assert_response :unauthorized

    params = { user: { username: @user.username, password: 'password' } }
    post sign_in_url, params: params
    assert_response 200
    logged_in_auth_header = response.headers['Authorization']
    assert_not_empty(logged_in_auth_header)
    assert_match(/\Abearer +\S+/i, logged_in_auth_header)

    get user_url(@user), headers: { Authorization: logged_in_auth_header }
    assert_response 200

    delete sign_out_url
    assert_response 204

    logged_out_auth_header = response.headers['Authorization']
    assert_not_equal(logged_out_auth_header, logged_in_auth_header)
    get user_url(@user), headers: { Authorization: logged_out_auth_header }
    assert_response :unauthorized

    post refresh_url
    assert_response :unauthorized
  end

  test "should refresh session" do
    get user_url(@user)
    assert_response :unauthorized

    params = { user: { username: @user.username, password: 'password' } }
    post sign_in_url, params: params
    assert_response 200
    logged_in_auth_header = response.headers['Authorization']
    assert_not_empty(logged_in_auth_header)
    assert_match(/\Abearer +\S+/i, logged_in_auth_header)

    get user_url(@user), headers: { Authorization: logged_in_auth_header }
    assert_response 200

    get user_url(@user)
    assert_response :unauthorized

    post refresh_url
    assert_response 200
    refreshed_auth_header = response.headers['Authorization']
    assert_not_empty(refreshed_auth_header)
    assert_match(/\Abearer +\S+/i, refreshed_auth_header)

    get user_url(@user), headers: { Authorization: refreshed_auth_header }
    assert_response 200
  end
end
