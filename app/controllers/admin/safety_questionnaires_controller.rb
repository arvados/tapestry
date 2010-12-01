class Admin::SafetyQuestionnairesController < Admin::AdminControllerBase

  include Admin::SafetyQuestionnairesHelper

  def index
    @unpaginated_safety_questionnaires = SafetyQuestionnaire.find(:all).sort { |x,y| y.datetime <=> x.datetime }
    @safety_questionnaires = @unpaginated_safety_questionnaires.paginate(:page => params[:page] || 1)
    respond_to do |format|
      format.html
      format.csv { send_data csv_for_safety_questionnaires(@unpaginated_safety_questionnaires), {
                     :filename    => 'PGP_Safety_Questionnaire_Responses.csv',
                     :type        => 'application/csv',
                     :disposition => 'attachment' } }
    end
  end

end
