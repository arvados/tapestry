class ContentAreasController < ApplicationController
  skip_before_filter :ensure_enrolled
  layout 'exam'

  def index
    @content_areas = ContentArea.ordered

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
