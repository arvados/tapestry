require 'test_helper'

class IdentityConfirmationsControllerTest < ActionController::TestCase
  should route( :get,  '/identity_confirmation' ).to( :controller => 'identity_confirmations', :action => 'show' )
  should route( :post, '/identity_confirmation' ).to( :controller => 'identity_confirmations', :action => 'create' )

  context "on GET to show" do
    setup { get :show }
    should 'redirect appropriately' do
      assert_redirected_to login_path
    end
  end

  context "on POST to create" do
    setup { post :create }
    should 'redirect appropriately' do
      assert_redirected_to login_path
    end
  end

  logged_in_user_context do
    context "on GET to show" do
      setup do
        get :show
      end

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
      setup do
        @count = EnrollmentStepCompletion.count
        post :create
      end

      should 'not increase step completion count' do
        assert_equal @count, EnrollmentStepCompletion.count
      end

      should respond_with :success
      should render_template :show

      should 'show an appropriate error' do
        assert_select 'div.alert-error', /enter your mailing address/i
      end

    end

    context "on POST to create with address fields" do
      setup do
        Factory :enrollment_step, :keyword => 'identity_confirmation'
        @count = EnrollmentStepCompletion.count
        post :create, :identity_confirmation => {
          :address1 => "address1-xyz",
          :address2 => "address2-xyz",
          :city     => "city-xyz",
          :state    => "state-xyz",
          :zip      => "zip-xyz"
        }
      end

      should "update the user address" do
        assert_equal "address1-xyz", @user.address1
        assert_equal "address2-xyz", @user.address2
        assert_equal "city-xyz",     @user.city
        assert_equal "state-xyz",    @user.state
        assert_equal "zip-xyz",      @user.zip
      end

      should 'increase step completion count' do
        assert_equal @count+1, EnrollmentStepCompletion.count
      end

      should 'redirect appropriately' do
        assert_redirected_to root_path
      end
    end
  end
end
