class ContentAreas::ExamDefinitionsController < ApplicationController
  before_filter :set_content_area

  def index
    redirect_to @content_area
  end

  def show
    @exam_definition = @content_area.exam_definitions.find(params[:id])
    @exam_response = ExamResponse.find_or_create_by_user_id_and_exam_definition_id(current_user, @exam_definition)
  end

  private

  def set_content_area
    @content_area = ContentArea.find params[:content_area_id]
  end
end
