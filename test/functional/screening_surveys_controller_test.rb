require 'test_helper'

class ScreeningSurveysControllerTest < ActionController::TestCase
  should "route /screening_surveys to ScreeningSurveysController#show" do
    assert_routing '/screening_surveys', :controller => 'screening_surveys',
                                         :action     => 'show'
  end

  public_context do
    context 'on GET to show' do
      setup do
        get :show
      end

      should respond_with :redirect
      should_redirect_to 'login_url'
    end
  end

  logged_in_user_context do
    context 'on GET to show' do
      setup do
        get :show
      end

      should respond_with :success
      should render_template :show
    end

    context "a user has completed all screening surveys" do
      setup do
        Factory(:screening_survey_response,   :user => @user)
        assert surveys_step    = EnrollmentStep.find_by_keyword('screening_surveys')
        @user.complete_enrollment_step(surveys_step)
        @user.reload
        assert @user.has_completed?('screening_surveys')
      end

    end

    context "on GET to show" do
      setup do
        post :update
      end

      should_redirect_to 'root_path'
      should set_the_flash.to /eligibility questionnaire/i
    end
  end

end
