class ScreeningSurveys::ResidenciesController < ApplicationController

  before_filter :redirect_to_new_if_no_response, :except => [:new]

  def new
    # Default valid response.
    ResidencySurveyResponse.create({
      :user                 => current_user,
      :us_resident          => true,
      :zip                  => '12345',
      :can_travel_to_boston => true
    })

    redirect_to edit_screening_surveys_residency_path
  end

  def edit
    @residency_survey_response = current_user.residency_survey_response
  end

  def update
    @residency_survey_response = current_user.residency_survey_response
    @residency_survey_response.update_attributes(params[:residency_survey_response])
    flash[:notice] = 'Success!'
    redirect_to edit_screening_surveys_residency_path
  end

  protected

  def redirect_to_new_if_no_response
    redirect_to new_screening_surveys_residency_path unless current_user.residency_survey_response
  end

end
