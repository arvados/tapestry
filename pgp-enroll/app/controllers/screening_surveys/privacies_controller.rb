class ScreeningSurveys::PrivaciesController < ApplicationController

  before_filter :fetch_or_create_response

  def edit
  end

  def update
    if @privacy_survey_response.update_attributes(params[:privacy_survey_response])
      flash[:success] = 'passed!'
      redirect_to screening_surveys_path
    else
      render :action => 'edit'
    end
  end

  # protected

  def fetch_or_create_response
    @privacy_survey_response = current_user.privacy_survey_response ||
                               PrivacySurveyResponse.new(:user => current_user)
  end

end
