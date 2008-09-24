class ExamsController < ApplicationController
  before_filter :set_content_area
  before_filter :set_exam_version, :only => [:show, :start, :retake]

  def index
    redirect_to @content_area
  end

  def show
    @exam_response = ExamResponse.find_by_user_id_and_exam_version_id(current_user, @exam_version)
  end

  def start
   ExamResponse.create(
      :user => current_user,
      :exam_version => @exam_version)

    redirect_to content_area_exam_exam_question_path(
        @content_area,
        @exam,
        @exam_version.exam_questions.first)
  end

  def retake
    @old_exam_response = current_user.exam_responses.find_by_exam_version_id(@exam_version)
    @old_exam_response.discard_for_retake! if @old_exam_response
    start
  end

  private

  def set_content_area
    @content_area = ContentArea.find params[:content_area_id]
  end

  def set_exam_version
    @exam = @content_area.exams.find(params[:id])
    @exam_version = @exam.version_for!(current_user)
  end
end
