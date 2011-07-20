require 'test_helper'

class OauthTokensControllerTest < ActionController::TestCase
  test "should get authorize" do
    get :authorize
    assert_response :success
  end

  test "should get revoke" do
    get :revoke
    assert_response :success
  end

end
