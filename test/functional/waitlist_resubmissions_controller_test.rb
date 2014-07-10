require 'test_helper'

class WaitlistResubmissionsControllerTest < ActionController::TestCase
  should route(:post, '/waitlist_resubmissions').to(:controller => 'waitlist_resubmissions', :action => 'create')

  context 'without a logged in user' do
    context "on POST to create" do
      setup { post :create }
      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end
  end

  context 'assuming screening_submission and screening_surveys are both enrollment steps' do
    setup do
      Factory :enrollment_step, :keyword => :screening_submission
      Factory :enrollment_step, :keyword => :screening_surveys
    end

    logged_in_user_context do
      context "on POST to create with a waitlist_id" do
        setup do
          @user = Factory(:user)

          Factory(:privacy_survey_response,   :user => @user)
          Factory(:residency_survey_response, :user => @user)
          Factory(:family_survey_response,    :user => @user)
          assert submission_step = EnrollmentStep.find_by_keyword('screening_submission')
          assert surveys_step    = EnrollmentStep.find_by_keyword('screening_surveys')

          @user.complete_enrollment_step(submission_step)
          @user.complete_enrollment_step(surveys_step)
          assert @user.has_completed?('screening_submission')
          assert @user.has_completed?('screening_surveys')

          @waitlist = Factory(:waitlist, :user => @user)
          assert_nil @waitlist.resubmitted_at
          post :create, :waitlist_id => @waitlist.id

          @user.reload
        end

        should "set the waitlist resubmitted_at" do
          assert_not_nil @waitlist.reload.resubmitted_at
        end

        should "remove previous responses" do
          assert_nil @user.privacy_survey_response
          assert_nil @user.residency_survey_response
          assert_nil @user.family_survey_response
        end

        should "remove the enrollment_step_completion" do
          @user.reload
          assert ! @user.has_completed?('screening_submission')
          assert ! @user.has_completed?('screening_surveys')
        end

        should 'redirect appropriately' do
          assert_redirected_to screening_surveys_path
        end
      end
    end
  end
end
