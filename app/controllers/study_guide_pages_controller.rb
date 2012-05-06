class StudyGuidePagesController < ApplicationController
  skip_before_filter :ensure_enrolled

  def index
    @ev = Exam.find(params[:exam_id]).current
   
    @sgp = @ev.study_guide_pages.where('ordinal = ?',1).first

    @content_area = ContentArea.find(@ev.exam.content_area.id)

    if @sgp.nil? then
      raise ActionController::RoutingError,
            "No such study guide page"
      return
    end 
  end

  def show
    @ev = Exam.find(params[:exam_id]).current
    if @ev.nil? then
      raise ActionController::RoutingError,
            "No such exam"
      return
    end

    @sgp = @ev.study_guide_pages.where('ordinal = ?',params[:ordinal]).first

    if @sgp.nil? then
      raise ActionController::RoutingError,
            "No such study guide page"
      return
    end

    @rel = @ev.study_guide_pages.where('ordinal = ?',params[:ordinal].to_i - 1)
    if not @rel.nil? then
      @sgp_previous = @rel.first
    else
      @sgp_previous = nil
    end

    @rel = @ev.study_guide_pages.where('ordinal = ?',params[:ordinal].to_i + 1)
    if not @rel.nil? then
      @sgp_next = @rel.first
    else
      @sgp_next = nil
    end

    @content_area = ContentArea.find(@ev.exam.content_area.id)

    @study_guide_page_count = @ev.study_guide_pages.size
  end

end
