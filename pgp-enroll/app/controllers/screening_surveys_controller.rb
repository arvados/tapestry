class ScreeningSurveysController < ApplicationController
  before_filter :redirect_to_enrollment_steps_if_screening_surveys_complete, :only => :index

  def index
    @privacy_survey_response   = current_user.privacy_survey_response
    @family_survey_response    = current_user.family_survey_response
    @residency_survey_response = current_user.residency_survey_response
  end

  private

  def redirect_to_enrollment_steps_if_screening_surveys_complete
    if current_user.has_completed?('screening_surveys')
      flash[:notice] = 'Completed screening surveys.'
      redirect_to root_path
    end
  end
end
