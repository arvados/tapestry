class ContentAreasController < ApplicationController
  def index
    @content_areas = ContentArea.all
  end

  def show
    @content_area = ContentArea.find params[:id]
    @exams = @content_area.exams
  end
end
