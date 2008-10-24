class ExamQuestionsController < ApplicationController
  before_filter :load_exam_models, :only => [:show, :answer]

  def show
    @answer_options = @exam_question.answer_options
  end

  def answer
    if params[:answer].respond_to?(:values)
      @answer = params[:answer].values.join(',')
    else
      @answer = params[:answer]
    end

    @question_reponse = QuestionResponse.new(
      :exam_response => @exam_response,
      :exam_question => @exam_question,
      :answer        => @answer)

    remove_existing_response

    if @question_reponse.save
      if @exam_question.last_in_exam?
        if @exam_response.correct?
          flash[:notice] = 'You correctly completed the exam.'
        else
          flash[:warning] = 'You must complete the exam correctly to proceed.'
        end
        redirect_to content_areas_url
      else
        redirect_to content_area_exam_exam_question_url(@content_area, @exam, @exam_question.next_question)
      end
    else
      show
      render :action => 'show'
    end
  end

  private

  def load_exam_models
    @content_area    = ContentArea.find params[:content_area_id]
    @exam            = @content_area.exams.find params[:exam_id]
    @exam_version    = @exam.version_for(current_user)
    @exam_response   = ExamResponse.find_by_user_id_and_exam_version_id(current_user, @exam_version)
    @exam_question   = @exam_version.exam_questions.find params[:id]
  end

  def remove_existing_response
    existing_response.destroy if existing_response
  end

  def existing_response
    @exam_response.question_responses.find(:first, :conditions => { :exam_question_id => @exam_question })
  end
end
