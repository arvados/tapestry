class Admin::ExamResponsesController < Admin::AdminControllerBase

  include Admin::UsersHelper

  def index
    @exam_responses = ExamResponse.all
  end

  def show
    @exam_response = ExamResponse.find params[:id]
  end

end
