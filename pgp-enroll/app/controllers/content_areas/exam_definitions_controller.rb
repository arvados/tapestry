class ContentAreas::ExamDefinitionsController < ApplicationController
  before_filter :set_content_area

  def index
    redirect_to @content_area
  end

  def show
    @exam_definition = @content_area.exam_definitions.find(params[:id])
  end

  private

  def set_content_area
    @content_area = ContentArea.find params[:content_area_id]
  end
end
