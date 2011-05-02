class Admin::ExamResponsesController < Admin::AdminControllerBase

  include Admin::UsersHelper
  helper_method :user

  def index
    # There is some bad data in our database. 
    # TODO: remove dead records (i.e. ExamResponse objects that point to non-existing exam versions)
    @exam_responses = user.exam_responses.delete_if { |e| e.exam_version.nil? }.sort_by { |r|
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
