class ScreeningSurveys::ResidenciesController < ApplicationController

  before_filter :fetch_or_create_response

  def edit
  end

  def update
    if @residency_survey_response.update_attributes(params[:residency_survey_response])
      if @residency_survey_response.eligible?
        flash[:notice] = 'You are eligible for participation in the PGP.'
      else
        flash[:warning] = <<-EOS
        Thank you for completing the residency survey.
        At this time, we can only accept qualified individuals
        (this text will change to reflect the reason for lack of eligibility,
        and what followup notification steps will take place.)
        EOS
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
