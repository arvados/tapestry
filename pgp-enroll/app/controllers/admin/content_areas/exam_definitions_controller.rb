class Admin::ContentAreas::ExamDefinitionsController < Admin::AdminControllerBase
  before_filter :set_content_area

  def index
    @exam_definitions = @content_area.exam_definitions.find(:all)
  end

  def show
    @exam_definition = @content_area.exam_definitions.find(params[:id])
  end

  def new
    @exam_definition = ExamDefinition.new
  end

  def edit
    @exam_definition = @content_area.exam_definitions.find(params[:id])
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
  end
end
