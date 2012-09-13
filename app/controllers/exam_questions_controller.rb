class ExamQuestionsController < ApplicationController
  layout 'exam'
  before_filter :load_exam_models, :only => [:show, :answer]
  skip_before_filter :ensure_enrolled

  def show
    @answer_options = @exam_question.answer_options.sort{ |a,b| a.answer <=> b.answer }
  end

  def answer
    if params[:answer].respond_to?(:values)
      @answer = params[:answer].values.join(',')
    else
      @answer = params[:answer]
    end
    @answer = '' if @answer.nil?

    @question_reponse = QuestionResponse.new(
      :exam_response => @exam_response,
      :exam_question => @exam_question,
      :answer        => @answer)

    remove_existing_response

    if @question_reponse.save
      if @exam_question.last_in_exam?
        if @exam_response.correct?
          flash[:notice] = 'You correctly completed this module.'
        else
          flash[:warning] = %[#{@exam_response.correct_response_count}
                              of #{@exam_response.response_count}
                              questions were answered correctly.
                              To proceed, you must retake the exam and
                              provide correct answers to all questions.]
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
    @content_area    = ContentArea.find_by_id(params[:content_area_id])
    if @content_area.nil?
      redirect_to root_url
      return
    end
    @exam            = @content_area.exams.find_by_id(params[:exam_id])
    if @exam.nil?
      redirect_to root_url
      return
    end
    @exam_version    = @exam.version_for(current_user)
    if @exam_version.nil?
      redirect_to root_url
      return
    end
    @exam_response   = ExamResponse.find_by_user_id_and_exam_version_id(current_user, @exam_version)
    # @exam_response is only present when /answer is called; it's ok to be nil otherwise
    @exam_question   = @exam_version.exam_questions.find_by_id(params[:id])
    if @exam_question.nil?
      redirect_to root_url
      return
    end
  end

  def remove_existing_response
    existing_response.destroy if existing_response
  end

  def existing_response
    @exam_response.question_responses.find(:first, :conditions => { :exam_question_id => @exam_question })
  end
end
