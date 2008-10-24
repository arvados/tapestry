class ContentAreasController < ApplicationController
  def index
    @content_areas = ContentArea.all

    if @current_content_area = ContentArea.current_for(current_user)
      @current_exam = @current_content_area.exams.current_for(current_user)
    else
      flash[:notice] = 'You correctly completed all entrance exams.'
      redirect_to root_url
    end
  end

  def show
    @content_area = ContentArea.find params[:id]
    @exams = @content_area.exams
  end
end
