class ProfilesController < ApplicationController
  layout 'profile'
  
  skip_before_filter :login_required, :only => [:public]
  skip_before_filter :ensure_enrolled, :only => [:public]

  include PhrccrsHelper

  def public
    @user = User.find_by_hex(params[:hex])
    # Invalid hex code
    return if @user.nil?

    @family_members = @user.family_relations

    @ccr = Ccr.find(:first, :conditions => {:user_id => @user.id}, :order => 'version DESC')

    survey = Survey.find(:first, :conditions => { :name => 'Absolute Pitch Survey' });
    @absolute_pitch_questions = []
    @absolute_pitch_questions = survey.survey_sections[0].survey_questions if not survey.nil? and not survey.survey_sections.nil?
    @absolute_pitch_answers = {}
    absolute_pitch_answer_mapping = { 'y' => 'Yes', 'n' => 'No', 'ns' => 'Not sure', 'na' => 'Not available', 13 => '>12' }
    @user.survey_answers.each {|a|
      if @absolute_pitch_answers[a.survey_question_id].nil?
        @absolute_pitch_answers[a.survey_question_id] = absolute_pitch_answer_mapping[a.text]
      end
    }
    nonces = Nonce.where(:owner_class => "User", :owner_id => @user.id, :target_class => "GoogleSurvey")
    @google_survey_results = []
    nonces.each {|n|
      response = {}
      response[:nonce] = n
      response[:survey] = GoogleSurvey.find(n.target_id)
      next if !response[:survey].is_result_public?
      response[:answers] = GoogleSurveyAnswer.find_all_by_nonce_id(n.id)
      next if response[:answers].empty?
      @google_survey_results.push response
    }
  end
end
