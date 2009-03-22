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

  context 'on GET to new' do
    setup do
      get :new
    end

    should 'render the signup page 1 form' do
      assert_select 'form[method=?][action=?]', 'get', new2_user_url do
        assert_select 'input[type=?][name=?]', 'text', 'user[first_name]'
        assert_select 'input[type=?][name=?]', 'text', 'user[middle_name]'
        assert_select 'input[type=?][name=?]', 'text', 'user[last_name]'
        assert_select 'input[type=?][name=?]', 'text', 'user[email]'
      end
    end
  end

  context 'on GET to new2 with bad values' do
    setup do
      get :new2, :user => {
        :first_name  => 'First',
        :middle_name => 'M',
        :last_name   => nil,
        :email       => 'bademail'
      }
    end

    should_respond_with :success
    should_render_template :new
  end

  context 'on GET to new2 with good values' do
    setup do
      get :new2, :user => {
        :first_name  => 'First',
        :middle_name => 'M',
        :last_name   => 'Last',
        :email       => 'user@example.org'
      }
    end

    should_respond_with :success
    should_render_template :new2

    should 'render the signup page 2 form' do
      assert_select 'form[method=?][action=?]', 'post', users_url do
        assert_select 'input[type=?][name=?]', 'hidden', 'user[first_name]'
        assert_select 'input[type=?][name=?]', 'hidden', 'user[middle_name]'
        assert_select 'input[type=?][name=?]', 'hidden', 'user[last_name]'
        assert_select 'input[type=?][name=?]', 'hidden', 'user[email]'
        assert_select 'input[type=?][name=?]', 'password', 'user[password]'
        assert_select 'input[type=?][name=?]', 'password', 'user[password_confirmation]'
      end
    end
  end

  context 'on POST to create with bad values' do
    setup do
      @controller.expects(:verify_recaptcha).returns(false)
      post :create, :user => {
        :first_name            => '',
        :middle_name           => '',
        :last_name             => '',
        :email                 => 'user@example.org',
        :password              => '',
        :password_confirmation => 'password'
      }
    end

    should_respond_with :success
    should_render_template :new2
  end

  context 'on POST to create with good values' do
    setup do
      @controller.expects(:verify_recaptcha).returns(true)

      post :create, :user => {
        :first_name            => 'First',
        :middle_name           => 'M',
        :last_name             => 'Last',
        :email                 => 'user@example.org',
        :password              => 'password',
        :password_confirmation => 'password'
      }
    end

    should_respond_with :redirect
    should_redirect_to 'login_url'
    should_change 'User.count', :by => 1
  end

  logged_in_user_context do
    context 'on GET to edit' do
      setup do
        get :edit, :id => @user.to_param
      end

      should_respond_with :success
      should_render_template :edit

      should 'include a link to request account deletion' do
        assert_select 'form[action=?]', user_url(@user) do
          assert_select 'input[type=submit]'
        end
      end
    end

    context 'on DELETE to destroy' do
      setup do
        delete :destroy, :id => @user.to_param
      end

      should_redirect_to 'page_url(:logged_out)'

      should 'send the email' do
        assert_sent_email do |email|
          email.subject =~ /delete/ &&
          email.to      == ['delete-account@personalgenomes.org'] &&
          email.body    =~ /#{@user.full_name}/
        end
      end
    end
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
