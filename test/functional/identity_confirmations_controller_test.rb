require 'test_helper'

class IdentityConfirmationsControllerTest < ActionController::TestCase
  should_route :get,  '/identity_confirmation', :controller => 'identity_confirmations', :action => 'show'
  should_route :post, '/identity_confirmation', :controller => 'identity_confirmations', :action => 'create'

  context "on GET to show" do
    setup { get :show }
    should_redirect_to "login_url"
  end

  context "on POST to create" do
    setup { post :create }
    should_redirect_to "login_url"
  end

  logged_in_user_context do
    context "on GET to show" do
      setup { get :show }

      should respond_with :success
      should render_template :show

      should "render a form to confirm identity" do
        assert_select 'form[method=?][action=?]', 'post', identity_confirmation_path do
          assert_select 'input[name=?]', 'identity_confirmation[address1]'
          assert_select 'input[name=?]', 'identity_confirmation[address2]'
          assert_select 'input[name=?]', 'identity_confirmation[city]'
          assert_select 'input[name=?]', 'identity_confirmation[state]'
          assert_select 'input[name=?]', 'identity_confirmation[zip]'
        end
      end
    end

    context "on POST to create without address fields" do
      setup { post :create }

      should_not_change 'EnrollmentStepCompletion.count'
      should respond_with :success
      should render_template :show

      should set_the_flash.to /enter your mailing address/i
    end

    context "on POST to create with address fields" do
      setup do
        post :create, :identity_confirmation => {
          :address1 => "address1",
          :address2 => "address2",
          :city     => "city",
          :state    => "state",
          :zip      => "zip"
        }
      end

      should "update the user address" do
        @user.reload
        assert_equal "address1", @user.address1
        assert_equal "address2", @user.address2
        assert_equal "city",     @user.city
        assert_equal "state",    @user.state
        assert_equal "zip",      @user.zip
      end

      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_redirect_to 'root_path'
    end
  end
end
