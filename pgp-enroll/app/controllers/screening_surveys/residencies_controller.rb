class ScreeningSurveys::ResidenciesController < ApplicationController

  def edit
    @residency_survey_response = current_user.residency_survey_response || ResidencySurveyResponse.new
  end

  def update
    @residency_survey_response = current_user.residency_survey_response
    @residency_survey_response.update_attributes(params[:residency_survey_response])
    flash[:notice] = 'Success!'
    redirect_to edit_screening_surveys_residency_path
  end

end
