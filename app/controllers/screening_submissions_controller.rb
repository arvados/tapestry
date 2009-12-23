class ScreeningSubmissionsController < ApplicationController
  def show
  end

  def create
    step = EnrollmentStep.find_by_keyword('screening_submission')
    current_user.complete_enrollment_step(step)
    flash[:notice] = "Thanks. Your eligibility application has been received, we will get back to you with results as soon as possible."
    redirect_to root_path
  end

  def destroy
    submission_step = EnrollmentStep.find_by_keyword('screening_submission')
    surveys_step    = EnrollmentStep.find_by_keyword('screening_surveys')

    submission_completion = EnrollmentStepCompletion.find_by_user_id_and_enrollment_step_id(current_user, submission_step)
    surveys_completion    = EnrollmentStepCompletion.find_by_user_id_and_enrollment_step_id(current_user, surveys_step)

    submission_completion.destroy
    surveys_completion.destroy

    current_user.family_survey_response.destroy    if current_user.family_survey_response
    current_user.residency_survey_response.destroy if current_user.residency_survey_response
    current_user.privacy_survey_response.destroy   if current_user.privacy_survey_response

    redirect_to screening_surveys_path
  end

  # private

  # def get_eligibility_and_message
  #   eligible = true
  #   message = ""

  #   [ current_user.family_survey_response,
  #     current_user.privacy_survey_response,
  #     current_user.residency_survey_response
  #   ].each do |survey_response|
  #     if survey_response && !survey_response.eligible?
  #       eligible = false
  #       message << "<p>#{survey_response.waitlist_message}</p>"
  #     end
  #   end

  #   [eligible, message]
  # end
end
