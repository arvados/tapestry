class Admin::ContentAreas::ExamDefinitions::ExamQuestionsController < Admin::AdminControllerBase
  add_breadcrumb 'Admin', '/admin'
  add_breadcrumb 'Content Areas', '/admin/content_areas'
  before_filter :set_content_area
  add_breadcrumb 'Exams', 'admin_content_area_exam_definitions_path(@content_area)'
  before_filter :set_exam_definition
  add_breadcrumb 'Questions', 'admin_content_area_exam_definition_exam_questions_path(@content_area, @exam_definition)'
  before_filter :set_exam_question, :only => [:show, :edit, :update]

  def index
    @exam_questions = @exam_definition.exam_questions
  end

  def show
  end

  def new
    @exam_question = ExamQuestion.new(:ordinal => @exam_definition.exam_questions.count + 1)]
  end

  def edit
  end

  def create
    @exam_question = ExamQuestion.new(params[:exam_question])
    @exam_question.type = params[:exam_question][:type]

    if @exam_question.save
      flash[:notice] = 'Question was successfully created.'
      redirect_to admin_content_area_exam_definition_exam_questions_path(@content_area, @exam_definition)
    else
      render :action => "new"
    end
  end

  def update
    if @exam_question.update_attributes(params[:exam_question]) &&
       @exam_question.update_attribute(:type, params[:exam_question][:type])
      flash[:notice] = 'ExamDefinition was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => "edit"
    end
  end

  def destroy
    @exam_question = @exam_definition.exam_questions.find(params[:id])
    @exam_question.destroy

    redirect_to :action => 'index'
  end

  private

  def set_content_area
    @content_area = ContentArea.find params[:content_area_id]
    add_breadcrumb @content_area.title, admin_content_area_path(@content_area)
  end

  def set_exam_definition
    @exam_definition = @content_area.exam_definitions.find(params[:exam_definition_id])
    add_breadcrumb @exam_definition.title, admin_content_area_exam_definition_path(@content_area, @exam_definition)
  end

  def set_exam_question
    @exam_question = @exam_definition.exam_questions.find(params[:id])
    add_breadcrumb @exam_question.question
  end
end
