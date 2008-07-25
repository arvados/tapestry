require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < Test::Unit::TestCase

  fixtures :users

  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should "login and redirect" do
    post :create, :email => 'quentin@example.com', :password => 'monkey'
    assert session[:user_id]
    assert_response :redirect
  end

  should "fail login and not redirect" do
    post :create, :email => 'quentin@example.com', :password => 'bad password'
    assert_nil session[:user_id]
    assert_response :success
  end

  should "logout" do  
    login_as :quentin
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end

  should "remember me" do
    @request.cookies["auth_token"] = nil
    post :create, :email => 'quentin@example.com', :password => 'monkey', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  should "not remember me" do
    @request.cookies["auth_token"] = nil
    post :create, :email => 'quentin@example.com', :password => 'monkey', :remember_me => "0"
    puts @response.cookies["auth_token"]
    assert @response.cookies["auth_token"].blank?
  end
  
  should "delete token on logout" do
    login_as :quentin
    get :destroy
    assert @response.cookies["auth_token"].blank?
  end

  should "login with cookie" do
    users(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end

  should "fail expired cookie login" do
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end

  should "fail cookie login" do
    users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
