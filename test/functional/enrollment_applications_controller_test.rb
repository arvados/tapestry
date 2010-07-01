require 'test_helper'

class EnrollmentApplicationsControllerTest < ActionController::TestCase
  should_route :get,  '/enrollment_application', :controller => 'enrollment_applications', :action => 'show'
  should_route :post, '/enrollment_application', :controller => 'enrollment_applications', :action => 'create'

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

      should_respond_with :success
      should_render_template :show

      should "render a form to apply for enrollment" do
        assert_select 'form[method=?][action=?]', 'post', enrollment_application_path do
          assert_select 'input[name=?]', 'commit'
        end
      end
    end

    context "on POST to create" do
      setup { post :create }

      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_redirect_to 'root_path'
      should_set_the_flash_to /thank you/i
    end

  end
end
