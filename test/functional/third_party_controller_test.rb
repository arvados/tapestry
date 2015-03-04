require 'test_helper'

class ThirdPartyControllerTest < ActionController::TestCase

  logged_in_enrolled_user_context do

    should 'get the index' do
      get :index
      assert_response :success
    end

  end
end