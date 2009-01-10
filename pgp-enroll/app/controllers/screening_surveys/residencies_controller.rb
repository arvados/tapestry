class ScreeningSurveys::ResidenciesController < ApplicationController

  before_filter :fetch_or_create_response

  def edit
  end

  def update
    if @residency_survey_response.update_attributes(params[:residency_survey_response])
      if @residency_survey_response.eligible?
        flash[:notice] = 'You have passed the residency survey successfully!  Please proceed to the next survey.'
      else
        flash[:warning] = @residency_survey_response.waitlist_message
      end

      redirect_to screening_surveys_path
    else
      render :action => 'edit'
    end
  end

  protected

  def fetch_or_create_response
    @residency_survey_response = current_user.residency_survey_response ||
                                 ResidencySurveyResponse.new(:user => current_user)
  end

end
