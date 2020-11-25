ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  def log_in_as(user, password = 'password', &block)
    post sign_in_url, params: { user: { username: user.username, password: password } }
    assert_response :success
    @auth_headers = { Authorization: response.headers['Authorization'] }
    yield @auth_headers if block_given?
  end
end
