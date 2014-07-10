require 'test_helper'
require 'users_controller'

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

      should respond_with :success
      should render_template :edit
    end

    context 'on DELETE to destroy' do
      setup do
        ActionMailer::Base.deliveries = []
        delete :destroy, :id => @user.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to page_path(:logged_out)
      end

      should 'send an email' do
        assert_equal 1, ActionMailer::Base.deliveries.size
        email = ActionMailer::Base.deliveries.first
        if defined? APP_CONFIG['withdrawal_notification_email']
          recipients = [extract_email(APP_CONFIG['withdrawal_notification_email'])]
        else
          recipients = [extract_email(APP_CONFIG['admin_email'])]
        end
        assert_equal recipients, email.to
        assert_match /deletion/i, email.subject
        assert_match /#{@user.full_name}/i, email.body
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

      should 'redirect appropriately' do
        assert_redirected_to root_path
      end

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

  def extract_email(s)
    /(?:"?([^"]*)"?\s)?(?:<?(.+@[^>]+)>?)/.match(s)[2]
  end
end
