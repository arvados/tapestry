require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'
require File.dirname(__FILE__) + '/../macros/login'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase

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

    context 'on PUT to update with good values' do
      setup do
        @mailing_list = Factory :mailing_list
        put :update, :id => @user.to_param, :user => { 
                                :email => @user.email,
                                :password => 'newpassword',
                                :password_confirmation => 'newpassword',
                                :mailing_list_ids => [ @mailing_list.id ]
                              }
      end

      should_redirect_to("root_url")

      should "update user password and mailing list subscriptions" do
        assert_equal @user, User.authenticate(@user.email, 'newpassword')
        assert_equal @user.mailing_list_ids, [ @mailing_list.id ]
      end
    end
  end


  protected

  def create_invited_user(options = {})
    post :create, { :user => Factory.attributes_for(:user).merge(options) }, { :invited => true }
  end
end
