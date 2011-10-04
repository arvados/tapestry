class AbsolutePitchSurveysController < ApplicationController
  skip_before_filter :login_required, :only => [:review]
  skip_before_filter :ensure_enrolled, :only => [:review]

  @@SURVEY_END_YES_ABSOLUTE_PITCH = 'End (answered yes to absolute pitch)'
  @@SURVEY_END_NO_ABSOLUTE_PITCH = 'End (answered no to absolute pitch)'

  def review
    @survey = Survey.find(:first, :conditions => { :name => 'Absolute Pitch Survey' });
    @answers = {}
    @answer_mapping = { 'y' => 'Yes', 'n' => 'No', 'ns' => 'Not sure', 'na' => 'Not available', 13 => '>12' }
    @user = User.find_by_hex(params[:id])
    if @user.nil?
      return not_found
    end

    if user_answers.select{|a| a.text == @@SURVEY_END_NO_ABSOLUTE_PITCH }.length > 0
      @survey_end_no_absolute_pitch = true;
    else
      @survey_end_yes_absolute_pitch = true;
    end

    user_answers.each {|a|
      if @answers[a.survey_question_id].nil?
        @answers[a.survey_question_id] = [ a.text ]
      else @answers[a.survey_question_id].kind_of?(Array)
        @answers[a.survey_question_id] << a.text
      end
    }
    @family_history = AbsolutePitchSurveyFamilyHistory.find(:all, :conditions =>
      ['survey_id = ? AND user_id = ?', @survey.id, @user.id])
  end

  def index
    if (params[:commit] == 'Retake Survey')
      current_user.log("Retake absolute pitch survey")
      current_user.absolute_pitch_survey_completion = nil
      end_answers = SurveyAnswer.find(:all, :joins => :survey_question, :conditions =>
        ['user_id = ? AND question_type = ?', current_user.id, 'end'])
      end_answers.each {|a| a.destroy()}
      current_user.save
      redirect_to :action => 'index'
    end

    if !current_user.absolute_pitch_survey_completion.nil?
      redirect_to :action => 'review', :id => current_user.hex
    end

    survey = Survey.find(:first, :conditions => { :name => 'Absolute Pitch Survey' })

    return if survey.nil?

    all_sections = survey.survey_sections
    if params[:id].nil?
      @survey_section = all_sections[0]
    else
      @survey_section = all_sections.find_all{|s| s.id == Integer(params[:id])}[0]
    end
    
    @first_section_id = all_sections[0].id
    @last_section_id = @first_section_id
    @last_section_id = all_sections[all_sections.length - 1].id if all_sections.length > 1
    if @survey_section.name == 'Family History'
      setup_family_history(survey)
      return
    end

    @answers = {}

    user_answers = current_user.survey_answers

    user_answers.each {|a|
      if @answers[a.survey_question_id].nil?
        @answers[a.survey_question_id] = [ a.text ]
      else @answers[a.survey_question_id].kind_of?(Array)
        @answers[a.survey_question_id] << a.text
      end
    }    
  end

  def setup_family_history(survey)
    @family_history = AbsolutePitchSurveyFamilyHistory.find(:all, :conditions =>
      ['survey_id = ? AND user_id = ?', survey.id, current_user.id])
    if @family_history.length == 0
      family_history = AbsolutePitchSurveyFamilyHistory.new
      family_history.relation = 'father'
      family_history.survey_id = survey.id
      family_history.user_id = current_user.id
      family_history.save
      @family_history << family_history
      family_history = AbsolutePitchSurveyFamilyHistory.new
      family_history.relation = 'mother'
      family_history.survey_id = survey.id
      family_history.user_id = current_user.id
      family_history.save
      @family_history << family_history
    end
  end

  def validate(section, answers)
    if section.previous_section_id.nil?
      answers.each {|a|
        if (a[1][:text].nil?)
          return false
        end
      }
    end
    return true
  end

  def save
    section_id = Integer(params[:id])
    survey_section = SurveySection.find(section_id)

    if params[:commit] == "Back"
      redirect_to :action => 'index', :id => survey_section.previous_section_id
      return
    end

    if params[:commit] == "Add Sibling"
      add_sibling_row(survey_section)
      return
    end
    
    if params[:commit] == "Remove Sibling"
      sibling_id = params[:remove_sibling_id].nil? ? 0 : params[:remove_sibling_id].to_i
      remove_sibling(survey_section, sibling_id)
      return
    end

    if survey_section.name == 'Family History'
      save_family_history(survey_section, true)
    else
      save_regular_answers(survey_section)
    end
  end

  def save_family_history(survey_section, continue_to_next_section)
    updated_family_history = params[:family_history]
    updated_family_history.each {|f|
      family_history = AbsolutePitchSurveyFamilyHistory.find(:first, :conditions =>
      ['id = ? AND survey_id = ? AND user_id = ?', f[1][:id], survey_section.survey_id, current_user.id])
      if !family_history.nil?
        family_history.relation = f[1][:relation]
        family_history.has_absolute_pitch = f[1][:has_absolute_pitch]
        family_history.plays_instrument = f[1][:plays_instrument]
        family_history.comments = f[1][:comments]
        family_history.save
      end
    }
    save_regular_answers(survey_section) if continue_to_next_section
  end

  def save_regular_answers(survey_section)
    user = params[:user]
    answers = user[:survey_answers]

    if !validate(survey_section, answers)
      flash[:error] = 'Please answer all questions in this section'
      index
      render :action => 'index'
      return
    end

    saved_answers = current_user.survey_answers
    if saved_answers.nil?
      saved_answers = []
    end

    last_answer = nil
    answers.each {|a|
      survey_question_id = a[1][:survey_question_id]
      answer_text_param = a[1][:text]
      if answer_text_param.kind_of?(Array)
        SurveyAnswer.delete_all(["survey_question_id = ? AND user_id = ?", survey_question_id, current_user.id])
        answer_text_param.each {|p|
          answer = SurveyAnswer.new
          answer.user_id = current_user.id
          answer.survey_question_id = survey_question_id
          answer.text = p
          answer.save
        }
      else 
        answer = SurveyAnswer.new
        answer.user_id = current_user.id
        answer.survey_question_id = survey_question_id
        answer.text = answer_text_param
        last_answer = answer.text unless
          answer.text == @@SURVEY_END_YES_ABSOLUTE_PITCH ||
          answer.text == @@SURVEY_END_NO_ABSOLUTE_PITCH
        dup = saved_answers.find_all{|sa| sa.survey_question_id == answer.survey_question_id}
        if dup.empty?
          answer.save
        else
          dup[0].text = answer.text
          dup[0].save
        end
      end
    }

    if survey_section.previous_section_id.nil? && last_answer != 'y'
      SurveyAnswer.delete_all(["user_id = ? AND text = ?", current_user.id,
        @@SURVEY_END_YES_ABSOLUTE_PITCH])
      current_user.absolute_pitch_survey_completion = Time.new
      current_user.save
      @survey_end_no_absolute_pitch = true
      current_user.log("Completed absolute pitch survey")
      render :action => 'index'
      return
    elsif survey_section.next_section_id.nil?
      SurveyAnswer.delete_all(["user_id = ? AND text = ?", current_user.id,
        @@SURVEY_END_NO_ABSOLUTE_PITCH])
      current_user.absolute_pitch_survey_completion = Time.new
      current_user.save
      @survey_end_yes_absolute_pitch = true
      @survey_section = nil
      current_user.log("Completed absolute pitch survey (full survey)")
      render :action => 'index'
      return
    end

    redirect_to :action => :index, :id => survey_section.next_section_id
  end

  def remove_sibling(survey_section, sibling_id)
    save_family_history(survey_section, false)
    @family_history = AbsolutePitchSurveyFamilyHistory.find(:all, :conditions =>
      ['id = ? AND survey_id = ? AND user_id = ?', sibling_id, survey_section.survey_id, current_user.id])
    @family_history.each {|f| f.destroy() }
    redirect_to :action => :index, :id => survey_section.id
  end

  def add_sibling_row(survey_section)
    save_family_history(survey_section, false)
    @family_history = AbsolutePitchSurveyFamilyHistory.find(:all, :conditions =>
      ['survey_id = ? AND user_id = ?', survey_section.survey_id, current_user.id])
    family_history = AbsolutePitchSurveyFamilyHistory.new
    family_history.survey_id = survey_section.survey_id
    family_history.user_id = current_user.id
    family_history.relation = ''
    family_history.save

    redirect_to :action => :index, :id => survey_section.id
  end
end
