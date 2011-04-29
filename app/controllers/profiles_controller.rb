class ProfilesController < ApplicationController
  layout 'profile'
  
  skip_before_filter :login_required, :only => [:public]
  skip_before_filter :ensure_enrolled, :only => [:public]

  include PhrccrsHelper

  def public
    @user = User.find_by_hex(params[:hex])
    # Invalid hex code
    return if not @user

    @family_members = @user.family_relations

    @ccr = Ccr.find(:first, :conditions => {:user_id => @user.id}, :order => 'version DESC')

    survey = Survey.find(:first, :conditions => { :name => 'Absolute Pitch Survey' });
    @absolute_pitch_questions = survey.survey_sections[0].survey_questions
    @absolute_pitch_answers = {}
    absolute_pitch_answer_mapping = { 'y' => 'Yes', 'n' => 'No', 'ns' => 'Not sure', 'na' => 'Not available', 13 => '>12' }
    @user.survey_answers.each {|a|
      if @absolute_pitch_answers[a.survey_question_id].nil?
        @absolute_pitch_answers[a.survey_question_id] = absolute_pitch_answer_mapping[a.text]
      end
    }
  end
end
