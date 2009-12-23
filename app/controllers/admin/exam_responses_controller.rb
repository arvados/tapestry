class Admin::ExamResponsesController < Admin::AdminControllerBase

  include Admin::UsersHelper
  helper_method :user

  def index
    @exam_responses = user.exam_responses.sort_by { |r|
      [r.exam_version.exam.content_area.ordinal,
       r.exam_version.exam.ordinal] }
  end

  def show
    @exam_response      = user.exam_responses.find(params[:id])
    @exam_version       = @exam_response.exam_version
    @exam               = @exam_version.exam
    @content_area       = @exam.content_area
    @question_responses = @exam_response.question_responses
  end

  protected

  def user
    User.find params[:user_id]
  end

end
