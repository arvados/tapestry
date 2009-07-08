class ScreeningSubmissionsController < ApplicationController
  def show
  end

  def create
    step = EnrollmentStep.find_by_keyword('screening_submission')
    current_user.complete_enrollment_step(step)
    flash[:notice] = "Thanks. Your eligibility application has been received, we will get back to you with results as soon as possible."
    redirect_to root_path
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
