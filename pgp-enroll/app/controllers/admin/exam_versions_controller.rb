class Admin::ExamVersionsController < Admin::AdminControllerBase
  add_breadcrumb 'Content Areas', '/admin/content_areas'
  before_filter :set_content_area
  before_filter :set_exam
  before_filter :set_exam_version, :only => [:show, :edit, :duplicate, :update, :destroy]

  def index
    @exam_versions = @exam.versions
  end

  def show
  end

  def new
    @exam_version = @exam.versions.new
  end

  def edit
  end

  def create
    @exam_version = @exam.versions.new(params[:exam_version])
    if @exam_version.save
      flash[:notice] = 'Exam version was successfully created.'
      redirect_to admin_content_area_exam_exam_versions_url(@content_area, @exam)
    else
      render :action => 'new'
    end
  end

  def duplicate
    @exam_version.duplicate!
    flash[:notice] = 'Exam version was successfully duplicated.'
    redirect_to admin_content_area_exam_exam_versions_url(@content_area, @exam)
  end

  def update
    if @exam_version.update_attributes(params[:exam_version])
      flash[:notice] = 'Exam version was successfully updated.'
      redirect_to admin_content_area_exam_exam_versions_url(@content_area, @exam)
    else
      render :action => "edit"
    end
  end

  def destroy
    @exam_version.destroy
    redirect_to admin_content_area_exam_exam_versions_url(@content_area, @exam)
  end

  private

  def set_content_area
    @content_area = ContentArea.find params[:content_area_id]
    add_breadcrumb @content_area.title, admin_content_area_path(@content_area)
  end

  def set_exam
    @exam = @content_area.exams.find params[:exam_id]

    add_breadcrumb @exam.title, admin_content_area_exam_path(@content_area, @exam)
  end

  def set_exam_version
    @exam_version = @exam.versions.find params[:id]
    add_breadcrumb @exam_version.title
  end
end
