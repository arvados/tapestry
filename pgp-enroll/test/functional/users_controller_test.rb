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

  context "on GET to new without an invite" do
    setup { get :new, {}, { :invited => false } }
    should_redirect_to("root_url")
    should_set_the_flash_to /You must enter an invited email address to sign up./i
  end

  context "on GET to new2 without an invite" do
    setup { get :new2, {}, { :invited => false } }
    should_redirect_to("root_url")
    should_set_the_flash_to /You must enter an invited email address to sign up./i
  end

  context "on POST to create without an invite" do
    setup { post :create, {}, { :invited => false } }
    should_redirect_to("root_url")
    should_set_the_flash_to /You must enter an invited email address to sign up./i
  end

  context "on GET activate without an invite" do
    setup { get :activate, {}, { :invited => false } }
    should "not require an invite" do
      assert_no_match /invited/, flash[:error] 
    end
  end

  context 'on GET to new when invited' do
    setup do
      get :new, {}, { :invited => true }
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

  context 'on GET to new2 with bad values when invited' do
    setup do
      get :new2, {
        :user => {
          :first_name  => 'First',
          :middle_name => 'M',
          :last_name   => nil,
          :email       => 'bademail'
        }
      }, { :invited => true }
    end

    should_respond_with :success
    should_render_template :new
  end

  context 'on GET to new2 with good values when invited' do
    setup do
      get :new2, {
        :user => {
          :first_name  => 'First',
          :middle_name => 'M',
          :last_name   => 'Last',
          :email       => 'user@example.org'
        }
      }, { :invited => true }
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

  context 'on POST to create with bad values when invited' do
    setup do
      @email = 'username@example.com'
      @invited_email = Factory(:invited_email, :email => @email)
      @controller.expects(:verify_recaptcha).returns(false)
      post :create, {
        :user => {
          :first_name            => '',
          :middle_name           => '',
          :last_name             => '',
          :email                 => 'user@example.org',
          :password              => '',
          :password_confirmation => 'password'
        }
      }, { :invited => true, :invited_email => @email}
    end

    should_respond_with :success
    should_render_template :new2

    should "not mark that invite as accepted" do
      assert ! @invited_email.reload.accepted_at
    end
  end

  context 'on POST to create with good values when invited' do
    setup do
      @email = 'username@example.com'
      @invited_email = Factory(:invited_email, :email => @email)
      @controller.expects(:verify_recaptcha).returns(true)

      post :create, {
        :user => {
          :first_name            => 'First',
          :middle_name           => 'M',
          :last_name             => 'Last',
          :email                 => 'user@example.org',
          :password              => 'password',
          :password_confirmation => 'password'
        }
      }, { :invited => true, :invited_email => @email }
    end

    should_respond_with :redirect
    should_redirect_to 'login_url'
    should_change 'User.count', :by => 1

    should "mark that invite as accepted" do
      assert @invited_email.reload.accepted_at
    end
  end

  def test_should_sign_up_user_with_activation_code
    create_invited_user
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


  protected

  def create_invited_user(options = {})
    post :create, { :user => Factory.attributes_for(:user).merge(options) }, { :invited => true }
  end
end
