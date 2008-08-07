class Admin::ExamDefinitionsController < Admin::AdminControllerBase
  def index
    @exam_definitions = ExamDefinition.find(:all)
  end

  def show
    @exam_definition = ExamDefinition.find(params[:id])
  end

  def new
    @exam_definition = ExamDefinition.new
    @content_areas = ContentArea.all
  end

  def edit
    @exam_definition = ExamDefinition.find(params[:id])
    @content_areas = ContentArea.all
  end

  def create
    @exam_definition = ExamDefinition.new(params[:exam_definition])

    if @exam_definition.save
      flash[:notice] = 'ExamDefinition was successfully created.'
      redirect_to(admin_exam_definitions_path)
    else
      @content_areas = ContentArea.all
      render :action => "new"
    end
  end

  def update
    @exam_definition = ExamDefinition.find(params[:id])

    if @exam_definition.update_attributes(params[:exam_definition])
      flash[:notice] = 'ExamDefinition was successfully updated.'
      redirect_to([:admin, @exam_definition])
    else
      render :action => "edit"
    end
  end

  def destroy
    @exam_definition = ExamDefinition.find(params[:id])
    @exam_definition.destroy

    redirect_to(admin_exam_definitions_url)
  end
end
