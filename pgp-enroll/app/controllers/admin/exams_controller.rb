class Admin::ExamsController < Admin::AdminControllerBase
  add_breadcrumb 'Content Areas', '/admin/content_areas'
  before_filter :set_content_area
  before_filter :set_exam, :only => [:show, :destroy]

  def index
    @exams = @content_area.exams
  end

  def show
    redirect_to admin_content_area_exam_exam_versions_url(@content_area, @exam)
  end

  def create
    @exam = @content_area.exams.new

    if @exam.save
      @exam.versions.create({:title => 'New exam', :description => 'New exam description' })
      flash[:notice] = 'Exam was successfully created.'
      redirect_to admin_content_area_exams_path(@content_area)
    else
      render :action => "new"
    end
  end

  def destroy
    @exam.destroy
    redirect_to admin_content_area_exams_path(@content_area)
  end

  private

  def set_content_area
    @content_area = ContentArea.find params[:content_area_id]
    add_breadcrumb @content_area.title, admin_content_area_path(@content_area)
  end

  def set_exam
    @exam = @content_area.exams.find params[:id]
    add_breadcrumb @exam.title
  end
end
