class Admin::ContentAreas::ExamDefinitionsController < Admin::AdminControllerBase
  add_breadcrumb 'Admin', '/admin'
  add_breadcrumb 'Content Areas', '/admin/content_areas'
  before_filter :set_content_area
  add_breadcrumb 'Exams', 'admin_content_area_exam_definitions_path(@content_area)'
  before_filter :set_exam_definition, :only => [:show, :edit]


  def index
    @exam_definitions = @content_area.exam_definitions.find(:all)
  end

  def show
  end

  def new
    @exam_definition = ExamDefinition.new
  end

  def edit
  end

  def create
    @exam_definition = ExamDefinition.new(params[:exam_definition])

    if @exam_definition.save
      flash[:notice] = 'ExamDefinition was successfully created.'
      redirect_to admin_content_area_exam_definitions_path(@content_area)
    else
      render :action => "new"
    end
  end

  def update
    @exam_definition = ExamDefinition.find(params[:id])

    if @exam_definition.update_attributes(params[:exam_definition])
      flash[:notice] = 'ExamDefinition was successfully updated.'
      redirect_to [:admin, @content_area, @exam_definition]
    else
      render :action => "edit"
    end
  end

  def destroy
    @exam_definition = ExamDefinition.find(params[:id])
    @exam_definition.destroy

    redirect_to admin_content_area_exam_definitions_path(@content_area)
  end

  private

  def set_content_area
    @content_area = ContentArea.find params[:content_area_id]
    add_breadcrumb @content_area.title, admin_content_area_path(@content_area)
  end

  def set_exam_definition
    @exam_definition = @content_area.exam_definitions.find(params[:id])
    add_breadcrumb @exam_definition.title
  end
end
