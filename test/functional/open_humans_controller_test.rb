require 'test_helper'

class OpenHumansControllerTest < ActionController::TestCase

  logged_in_enrolled_user_context do

    context 'existing service but no existing token' do

      setup do
        @oauth_service = Factory(:open_humans_oauth_service)
        ApplicationController.any_instance.stubs('include_section?').with(Section::OPEN_HUMANS).returns(true)
      end

      should 'issue a redirect when a token needs to be creted' do
        get :create_token, :service_id => @oauth_service.id
        assert_response :redirect
      end

      should 'create a token when called back' do
        token_hash = { :expires_at => (Time.now + 1.hour).to_i }
        @user.oauth_tokens.delete_all
        OauthService.expects(:find_by_oauth2_service_type).with(OauthService::OPEN_HUMANS).returns(@oauth_service)
        get_token_stub = stub( :to_hash => token_hash  )
        auth_code_stub = stub( :get_token => get_token_stub )
        client_stub = stub( :auth_code => auth_code_stub )
        OpenHumansController.any_instance.expects(:client).with(@oauth_service).returns(client_stub)
        get :callback, :code => '12345'
        oauth_token = @user.oauth_tokens.first
        assert_equal oauth_token.oauth2_token_hash, token_hash
        assert_redirected_to third_party_index_path
      end

    end
  end
end