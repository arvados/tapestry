class SafetyQuestionnairesController < ApplicationController
  skip_before_filter :ensure_recent_safety_questionnaire

  def require
  end

  def index
    @safety_questionnaires = current_user.safety_questionnaires.sort { |x,y| y.datetime <=> x.datetime }
  end

  def new
    @safety_questionnaire = SafetyQuestionnaire.new()
  end

  def show
    # find_by_id returns nil when the record does not exist; find throws an ActiveRecord::RecordNotFound
    @safety_questionnaire = SafetyQuestionnaire.find_by_id(params[:id])
    if @safety_questionnaire.nil? or @safety_questionnaire.user != current_user then
      flash[:error] = 'Invalid id'
      redirect_to root_url
    end
  end

  def create
    @safety_questionnaire = SafetyQuestionnaire.new(params[:safety_questionnaire])
    @safety_questionnaire.user = current_user
    @safety_questionnaire.datetime = Time.now()
    if @safety_questionnaire.save
      flash[:notice] = 'Safety Questionnaire answers successfully saved.'
      redirect_to root_path
    else
      render :action => 'new'
    end
  end

end
