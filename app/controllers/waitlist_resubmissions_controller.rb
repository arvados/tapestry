class WaitlistResubmissionsController < ApplicationController
  skip_before_filter :ensure_enrolled

  def create
    waitlist = Waitlist.find(params[:waitlist_id])
    waitlist.update_attribute(:resubmitted_at, Time.now)

    user = waitlist.user

    submission_step = EnrollmentStep.find_by_keyword('screening_submission')
    surveys_step    = EnrollmentStep.find_by_keyword('screening_surveys')

    submission_completion = EnrollmentStepCompletion.find_by_user_id_and_enrollment_step_id(user, submission_step)
    surveys_completion    = EnrollmentStepCompletion.find_by_user_id_and_enrollment_step_id(user, surveys_step)

    submission_completion.destroy if submission_completion
    surveys_completion.destroy if surveys_completion

    user.family_survey_response.destroy    if user.family_survey_response
    user.residency_survey_response.destroy if user.residency_survey_response
    user.privacy_survey_response.destroy   if user.privacy_survey_response

    redirect_to screening_surveys_path
  end
end
