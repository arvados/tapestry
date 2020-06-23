
class GoogleSurveyRemindersController < ApplicationController
  before_filter {|c| c.check_section_disabled(Section::GOOGLE_SURVEYS) }
  before_filter :store_location

  # GET /google_survey_reminders/edit
  def edit
    @gs = GoogleSurvey.find_by_id(params[:google_survey_id])
    if @gs == nil
      flash[:error] = "Google Survey ID missing."
      redirect_back_or_default(root_path)
    end
    @gsr = GoogleSurveyReminder.where(:user_id => current_user.id, :google_survey_id => @gs.id).first
    if @gsr == nil
      @gsr = GoogleSurveyReminder.new
      @gsr.google_survey = GoogleSurvey.find_by_id(params[:google_survey_id])
    end
    @frequency_options = [['Disabled', 0]]
    @gsr.google_survey.reminder_email_frequency.split(',').each do |freq|
      fname = freq
      if freq == "1"
        fname = 'Daily'
      elsif freq == "2"
        fname = 'Every other day'
      elsif freq == "7"
        fname = 'Weekly'
      end
      @frequency_options << [fname, freq]
    end
  end

  # POST /google_survey_reminders/update
  def update
    @gsr = GoogleSurveyReminder.where(:user_id => current_user, :google_survey_id => params[:google_survey_id]).first
    if @gsr == nil
      @gsr = GoogleSurveyReminder.new()
      @gsr.user = current_user
      @gsr.google_survey_id = params[:google_survey_id]
    end
    @gsr.frequency = params[:frequency]
    if @gsr.save
      redirect_to(@gsr.google_survey, :notice => 'Reminder settings were successfully updated.')
    else
      render :action => "edit"
    end
  end

end
