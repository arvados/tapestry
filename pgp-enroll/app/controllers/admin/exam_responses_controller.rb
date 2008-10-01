class Admin::ExamResponsesController < Admin::AdminControllerBase

  include Admin::UsersHelper

  def index
    @exam_responses = ExamResponse.all
  end

  def show
    @exam_response      = ExamResponse.find params[:id]
    @exam_version       = @exam_response.exam_version
    @exam               = @exam_version.exam
    @content_area       = @exam.content_area
    @question_responses = @exam_response.question_responses
  end

end
