class Admin::ExamVersionsController < Admin::AdminControllerBase
  add_breadcrumb 'Content Areas', '/admin/content_areas'
  before_filter :set_content_area
  before_filter :set_exam
  before_filter :set_exam_version, :only => [:show, :edit, :update]

  def index
  end

  def show
  end

  def new
    @exam_version = ExamVersion.new
  end

  def edit
  end

  def create
    @exam_version = ExamVersion.new(params[:exam_definition])

    if @exam_definition.save
      flash[:notice] = 'ExamDefinition was successfully created.'
      redirect_to admin_content_area_exam_definitions_path(@content_area)
    else
      render :action => "new"
    end
  end

  def update
    if @exam_definition.update_attributes(params[:exam_definition])
      flash[:notice] = 'ExamDefinition was successfully updated.'
      redirect_to [:admin, @content_area, @exam_definition]
    else
      render :action => "edit"
    end
  end

  def destroy
    @exam_definition = @content_area.exam_definitions.find(params[:id])
    @exam_definition.destroy

    redirect_to :action => :index
  end

  private

  def set_content_area
    @content_area = ContentArea.find params[:content_area_id]
    add_breadcrumb @content_area.title, admin_content_area_path(@content_area)
  end

  def set_exam
    @exam = @content_area.exams.find params[:id]

    add_breadcrumb @exam.title, admin_content_area_exam_path(@content_area, @exam)
  end

  def set_exam_version
    @exam_version = @exam.versions.find params[:id]
    add_breadcrumb @exam_version.title
  end
end
