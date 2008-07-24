require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should "allow signup" do
    assert_difference 'User.count' do
      create_user
      assert_response :redirect
    end
  end

  should "require login on signup" do
    assert_no_difference 'User.count' do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  should "require password on signup" do
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  should "require password confirmation on signup" do
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  should "require email on signup" do
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end
  

  
  should "sign up user with activation code" do
    create_user
    assigns(:user).reload
    assert_not_nil assigns(:user).activation_code
  end

  should "activate user" do
    assert_nil User.authenticate('aaron', 'test')
    get :activate, :activation_code => users(:aaron).activation_code
    assert_redirected_to '/session/new'
    assert_not_nil flash[:notice]
    assert_equal users(:aaron), User.authenticate('aaron', 'monkey')
  end
  
  should "not activate user without key" do
    begin
      get :activate
      assert_nil flash[:notice]
    rescue ActionController::RoutingError
      # in the event your routes deny this, we'll just bow out gracefully.
    end
  end

  should "not activate user with blank key" do
    begin
      get :activate, :activation_code => ''
      assert_nil flash[:notice]
    rescue ActionController::RoutingError
      # well played, sir
    end
  end

  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
    end
end
