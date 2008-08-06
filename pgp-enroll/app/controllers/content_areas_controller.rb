class ContentAreasController < ApplicationController
  def index
    @content_areas = ContentArea.all
  end

  def show
    @content_area = ContentArea.find params[:id]
    @exam_definitions = @content_area.exam_definitions
  end
end
