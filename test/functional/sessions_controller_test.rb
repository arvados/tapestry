require File.dirname(__FILE__) + '/../test_helper'
require 'sessions_controller'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < Test::Unit::TestCase

  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @password   = 'secret'
    @user       = Factory(:user, :password => @password, :password_confirmation => @password)
    @user.activate!
  end

  should "login and redirect" do
    post :create, :email => @user.email, :password => @user.password
    assert session[:user_id]
    assert_response :redirect
  end

  should "fail login and not redirect" do
    post :create, :email => @user.email, :password => 'bad password'
    assert_nil session[:user_id]
    assert_response :success
  end

  should "logout" do  
    login_as @user
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
    assert_redirected_to page_url(:logged_out)
  end

  should "remember me" do
    @request.cookies["auth_token"] = nil
    post :create, :email => @user.email, :password => @user.password, :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  should "not remember me" do
    @request.cookies["auth_token"] = nil
    post :create, :email => @user.email, :password => @user.password, :remember_me => "0"
    assert @response.cookies["auth_token"].blank?
  end
  
  should "delete token on logout" do
    login_as @user
    get :destroy
    assert @response.cookies["auth_token"].blank?
  end

  should "login with cookie" do
    @user.remember_me
    @request.cookies["auth_token"] = cookie_for(@user)
    get :new
    assert @controller.send(:logged_in?)
  end

  should "fail expired cookie login" do
    @user.remember_me
    @user.update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(@user)
    get :new
    assert !@controller.send(:logged_in?)
  end

  should "fail cookie login" do
    @user.remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end

    def cookie_for(user)
      auth_token user.remember_token
    end
end
