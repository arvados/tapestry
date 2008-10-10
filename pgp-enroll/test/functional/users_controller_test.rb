require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_signup
    assert_difference 'User.count' do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end
  

  
  def test_should_sign_up_user_with_activation_code
    create_user
    assigns(:user).reload
    assert_not_nil assigns(:user).activation_code
  end

  def test_should_activate_user
    @password = 'monkey'

    @aaron = Factory(:user, :password => @password, :password_confirmation => @password)
    assert_nil User.authenticate(@aaron.email, @password)
    User.any_instance.expects(:activate!)
    get :activate, :code => @aaron.activation_code
    assert_redirected_to '/login'
    assert_not_nil flash[:notice]
  end
  
  def test_should_not_activate_user_without_key
    get :activate
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end

  def test_should_not_activate_user_with_blank_key
    get :activate, :code => ''
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # well played, sir
  end

  protected

  def create_user(options = {})
    post :create, :user => Factory.attributes_for(:user).merge(options)
  end
end
