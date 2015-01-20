require 'test_helper'

class OpenHumansControllerTest < ActionController::TestCase

  logged_in_enrolled_user_context do

    context 'existing service' do

      setup do
        ApplicationController.any_instance.stubs('include_section?').with(Section::OPEN_HUMANS).returns(true)
      end

      context 'but no existing token' do

        setup do
          @oauth_service = Factory(:open_humans_oauth_service)
        end

        should 'issue a redirect when a token needs to be creted' do
          get :create_token, :service_id => @oauth_service.id
          assert_response :redirect
        end

        should 'create a token when called back' do
          @user.oauth_tokens.delete_all
          OauthService.expects(:find_by_oauth2_service_type).with(OauthService::OPEN_HUMANS).returns(@oauth_service)
          token_hash = Factory( :open_humans_token ).oauth2_token_hash
          stub_client( token_hash )
          get :callback, :code => '12345'
          oauth_token = @user.oauth_tokens.first
          assert_equal oauth_token.oauth2_token_hash, token_hash
          assert_redirected_to third_party_index_path
        end

      end

      context 'with existing token but no registered huids' do
        setup do
          @oauth_token = Factory(:open_humans_token)
          @user.oauth_tokens << @oauth_token
          @oauth_service = @oauth_token.oauth_service
          stub_client( @oauth_token.oauth2_token_hash )
        end

        should 'successfully register current huid' do
          stub_client( @oauth_token.oauth2_token_hash, @huids, 201 )
          post :create_huid, :format => :json, :token_id => @oauth_token.id
          assert_response :success
        end
      end

      context 'with existing token and registered huids' do

        setup do
          @huids = [ @user.hex ]
          @oauth_token = Factory(:open_humans_token)
          @user.oauth_tokens << @oauth_token
          @oauth_service = @oauth_token.oauth_service
          stub_client( @oauth_token.oauth2_token_hash, @huids )
        end

        should 'try to get a list of huids for the current user' do
          get :huids, :format => :json, :token_id => @oauth_token.id
          assert_response :success
          assert_equal JSON.parse(response.body)['huids'], [ @user.hex ]
        end

        should 'acknowledge existing huids' do
          get :huids, :format => :json, :token_id => @oauth_token.id
          assert_response :success
          assert_equal @huids, JSON.parse(response.body)['huids']
        end

        should 'delete existing huids' do
          delete :huids, :format => :json, :token_id => @oauth_token.id
          assert_response :success
          stub_client( @oauth_token.oauth2_token_hash, [])
          get :huids, :format => :json, :token_id => @oauth_token.id
          assert_response :success
          assert_equal [], JSON.parse(response.body)['huids']
        end

        should 'fail to add the current user huid because it already exists' do
          stub_client( @oauth_token.oauth2_token_hash, @huids, 500 )
          post :create_huid, :format => :json, :token_id => @oauth_token.id
          assert_response :error
        end
      end
    end
  end

private

  def stub_client( token_hash, huids = [], api_response_status = 200 )
    api_response_stub = stub( :parsed => { 'id' => 1, 'huids' => huids },
                              :status => api_response_status )
    get_token_stub = stub( :to_hash =>  token_hash  )
    get_token_stub.stubs(:get).with( OpenHumansController::USER_DATA_URL,
                                     {:headers => {'Content-Type' => 'application/json'}} ).returns( api_response_stub )
    get_token_stub.stubs(:post).with( OpenHumansController::POST_HUIDS_URL,
                                     {:headers => {'Content-Type' => 'application/json'},
                                      :body => { :value => @user.hex }.to_json } ).returns( api_response_stub )
    get_token_stub.stubs('expired?').returns(false)
    auth_code_stub = stub( :get_token => get_token_stub )
    client_stub = stub( :auth_code => auth_code_stub )
    OpenHumansController.any_instance.stubs(:client).with(@oauth_service).returns(client_stub)
    OAuth2::AccessToken.stubs( :from_hash ).with( client_stub, token_hash ).returns(get_token_stub)
  end

end