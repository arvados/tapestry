require 'test_helper'

class OauthTokensControllerTest < ActionController::TestCase

  logged_in_user_context do
    should_eventually "GET authorize, GET revoke, GET index, GET get_access_token"
  end

end
