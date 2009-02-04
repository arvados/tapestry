class ScreeningSurveys::FamiliesController < ApplicationController

  before_filter :fetch_or_create_response

  def edit
  end

  def update
    if @family_survey_response.update_attributes(params[:family_survey_response])
      if @family_survey_response.eligible?
        flash[:notice] = 'You have passed the family consideration survey. Please proceed to the next survey.'
      else
        flash[:warning] = @family_survey_response.waitlist_message
      end
      redirect_to screening_surveys_path
    else
      render :action => 'edit'
    end
  end

  protected

  def fetch_or_create_response
    @family_survey_response = current_user.family_survey_response ||
                              FamilySurveyResponse.new(:user => current_user)
  end

end
