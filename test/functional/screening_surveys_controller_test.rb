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

      should_respond_with :redirect
      should_redirect_to 'login_url'
    end
  end

  logged_in_user_context do
    context 'on GET to show' do
      setup do
        get :show
      end

      should_respond_with :success
      should_render_template :show
    end

    context "a user has completed all screening surveys" do
      setup do
        Factory(:screening_survey_response,   :user => @user)
        assert surveys_step    = EnrollmentStep.find_by_keyword('screening_surveys')
        @user.complete_enrollment_step(surveys_step)
        @user.reload
        assert @user.has_completed?('screening_surveys')

#      end
      
#      setup do
##        surveys_step    = EnrollmentStep.find_by_keyword('screening_surveys')
##        @user.complete_enrollment_step(surveys_step)
##        @user.reload
##        Factory(:enrollment_step_completion, :user => @user, :enrollment_step => surveys_step)
##        Factory(:screening_survey_response, :user => @user)
#
## W T F is going on here...
#assert submission_step = EnrollmentStep.find_by_keyword('screening_submission')
#        assert surveys_step    = EnrollmentStep.find_by_keyword('screening_surveys')
#        @user.complete_enrollment_step(submission_step)
#        @user.complete_enrollment_step(surveys_step)
#        @user.reload
#        assert @user.has_completed?('screening_submission')
#        assert @user.has_completed?('screening_surveysxx')
#
#
#
#      end
#
#      context "on GET to show" do
#        setup do
          get :show
        end

        should_redirect_to 'root_path'
        should_set_the_flash_to /completed/i
      end
    end


#  end

end
