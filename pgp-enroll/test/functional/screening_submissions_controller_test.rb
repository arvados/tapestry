require 'test_helper'

class ScreeningSubmissionsControllerTest < ActionController::TestCase
  should_route :get,  '/screening_submission', :controller => 'screening_submissions', :action => 'show'
  should_route :post, '/screening_submission', :controller => 'screening_submissions', :action => 'create'

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

      should "render a form to create a screening submission" do
        assert_select 'form[method=?][action=?]', 'post', screening_submission_path
      end
    end

    context "on POST to create with all eligible screening surveys" do
      setup do
        FamilySurveyResponse.any_instance.stubs(:eligible?).returns(true)
        ResidencySurveyResponse.any_instance.stubs(:eligible?).returns(true)
        PrivacySurveyResponse.any_instance.stubs(:eligible?).returns(true)

        post :create
      end

      should_change "EnrollmentStepCompletion.count", :by => 1
      should_set_the_flash_to /your eligibility application has been received/i

      should_redirect_to "root_path"
    end

    # context "on POST to create with some ineligible screening surveys" do
    #   setup do
    #     @family_survey_response = Factory(:ineligible_family_survey_response, :user => @user)
    #     post :create
    #   end

    #   should_change "EnrollmentStepCompletion.count", :by => 1

    #   should_redirect_to "root_path"

    #   should_set_the_flash_to /thank you for your interest/i
    # end
  end
end
