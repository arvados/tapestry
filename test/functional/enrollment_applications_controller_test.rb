require 'test_helper'

class EnrollmentApplicationsControllerTest < ActionController::TestCase
  should route( :get,  '/enrollment_application' ).to( :action => 'show' )
  should route( :post, '/enrollment_application' ).to( :action => 'create' )

  context "not logged in" do
    context "on GET to show" do
      setup { get :show }

      should 'do the redirection to the login page' do
        assert_redirected_to login_url
      end
    end

    context "on POST to create" do
      setup { post :create }

      should 'do the redirection to the login page' do
        assert_redirected_to login_url
      end
    end
  end

  logged_in_user_context do
    context "on GET to show" do
      setup { get :show }

      should respond_with :success
      should render_template :show

      should "render a form to apply for enrollment" do
        assert_select 'form[method=?][action=?]', 'post', enrollment_application_path do
          assert_select 'input[name=?]', 'commit'
        end
      end
    end

    context "on POST to create" do
      setup do
        @count = EnrollmentStepCompletion.count
        post :create
      end

      should 'change EnrollmentStepCompletion.count by 1' do
        @count + 1 == EnrollmentStepCompletion.count
      end

      should 'do the redirection to the right page' do
        assert_redirected_to root_path
      end

      should set_the_flash.to /thank you/i
    end

  end
end
