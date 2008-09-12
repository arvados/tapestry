class ExamsController < ApplicationController
  before_filter :set_content_area
  before_filter :set_exam_definition, :only => [:show, :start, :retake]

  def index
    redirect_to @content_area
  end

  def show
    @exam_response = ExamResponse.find_by_user_id_and_exam_definition_id(current_user, @exam_definition)
  end

  def start
   ExamResponse.create(
      :user => current_user,
      :exam_definition => @exam_definition)

    redirect_to content_area_exam_definition_exam_question_path(
        @content_area,
        @exam_definition,
        @exam_definition.exam_questions.first)
  end

  def retake
    @old_exam_response = current_user.exam_responses.find_by_exam_definition_id(@exam_definition)
    @old_exam_response.discard_for_retake! if @old_exam_response
    start
  end

  private

  def set_content_area
    @content_area = ContentArea.find params[:content_area_id]
  end

  def set_exam_definition
    @exam_definition = @content_area.exam_definitions.find(params[:id])
  end
end
