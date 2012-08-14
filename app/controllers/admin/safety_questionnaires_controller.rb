class Admin::SafetyQuestionnairesController < Admin::AdminControllerBase

  include Admin::SafetyQuestionnairesHelper

  def index
    @question = params[:question]
    @unpaginated_safety_questionnaires = SafetyQuestionnaire.find(:all, 
                                                                  :include => 'user', 
                                                                  :conditions => { 'users.is_test' => 'false' }).sort { |x,y| y.datetime <=> x.datetime }
    @safety_questionnaires = @unpaginated_safety_questionnaires.paginate(:page => params[:page] || 1)
    respond_to do |format|
      format.html
      format.csv { send_data csv_for_safety_questionnaires(@unpaginated_safety_questionnaires,@question), {
                     :filename    => @question.nil? ? "PGP_Safety_Questionnaire_Responses.csv" : "PGP_Safety_Questionnaire_Responses_question_#{@question}.csv",
                     :type        => 'application/csv',
                     :disposition => 'attachment' } }
    end
  end

end
