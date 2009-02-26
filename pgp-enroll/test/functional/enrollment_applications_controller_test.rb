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
          assert_select 'textarea[name=?]', 'essay'
        end
      end
    end

    context "on POST to create with a valid essay" do
      setup { post :create, :essay => 'word ' * 200 }

      should_change '@user.reload.enrollment_essay', :to => 'word ' * 200
      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_redirect_to 'root_path'
      should_set_the_flash_to /thank you/i
    end

    context "on POST to create with no essay" do
      setup { post :create }

      should_not_change 'EnrollmentStepCompletion.count'
      should_respond_with :success
      should_render_template :show

      should_set_the_flash_to /essay/i
    end

    context "on POST to create with an essay that is too long" do
      setup { post :create, :essay => "word " * 201 }

      should_not_change 'EnrollmentStepCompletion.count'
      should_respond_with :success
      should_render_template :show

      should_set_the_flash_to /200 words/i
    end

    context "on POST to create with an essay that is too short" do
      setup { post :create, :essay => "word " * 19 }

      should_not_change 'EnrollmentStepCompletion.count'
      should_respond_with :success
      should_render_template :show

      should_set_the_flash_to /20&ndash;200 words/i
    end
  end
end
