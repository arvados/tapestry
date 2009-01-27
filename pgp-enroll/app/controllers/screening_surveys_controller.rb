class ScreeningSurveysController < ApplicationController
  def index
    @privacy_survey_response   = current_user.privacy_survey_response
    @family_survey_response    = current_user.family_survey_response
    @residency_survey_response = current_user.residency_survey_response
  end

  def complete
    unless EnrollmentStep.find_by_keyword('screening_surveys').completers.include?(current_user)
      current_user.enrollment_step_completions.create({
        :enrollment_step => EnrollmentStep.find_by_keyword('screening_surveys'),
      })
      flash[:notice] = 'Completed screening surveys.'
    end

    redirect_to root_url
  end
end
