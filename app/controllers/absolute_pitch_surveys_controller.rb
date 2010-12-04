class AbsolutePitchSurveysController < ApplicationController

  def review
    @survey = Survey.find(1);
    @answers = {}
    @answer_mapping = { 'y' => 'Yes', 'n' => 'No', 'ns' => 'Not sure', 'na' => 'Not available', 13 => '>12' }
    user_answers = current_user.survey_answers
    if user_answers.select{|a| a.survey_question_id == 21 }.length > 0
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
  end

  def index
    if !current_user.absolute_pitch_survey_completion.nil?
      redirect_to :action => 'review'
    end
    survey = Survey.find(1);   
    @answers = {}

    user_answers = current_user.survey_answers

    user_answers.each {|a|
      if @answers[a.survey_question_id].nil?
        @answers[a.survey_question_id] = [ a.text ]
      else @answers[a.survey_question_id].kind_of?(Array)
        @answers[a.survey_question_id] << a.text
      end
    }
    if params[:id].nil?
      @survey_section = survey.survey_sections[0]
    else
      @survey_section = SurveySection.find(Integer(params[:id]))
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
        last_answer = answer.text
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
        SurveyAnswer.delete_all(["survey_question_id = ? AND user_id = ?", 20, current_user.id])
      current_user.absolute_pitch_survey_completion = Time.new
      current_user.save
      @survey_end_no_absolute_pitch = true
      render :action => 'index'
      return
    elsif survey_section.next_section_id.nil?
        SurveyAnswer.delete_all(["survey_question_id = ? AND user_id = ?", 21, current_user.id])
      current_user.absolute_pitch_survey_completion = Time.new
      current_user.save
      @survey_end_yes_absolute_pitch = true
      @survey_section = nil
      render :action => 'index'
      return
    end

    redirect_to :action => :index, :id => survey_section.next_section_id
  end
end
