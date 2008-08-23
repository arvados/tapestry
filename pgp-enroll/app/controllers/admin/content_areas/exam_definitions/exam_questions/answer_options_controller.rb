class Admin::ContentAreas::ExamDefinitions::ExamQuestions::AnswerOptionsController < Admin::AdminControllerBase
  add_breadcrumb 'Content Areas', '/admin/content_areas'
  before_filter :set_content_area
  before_filter :set_exam_definition
  before_filter :set_exam_question
  before_filter :set_answer_option, :only => [:show, :edit, :update]

  def index
    @answer_options = @exam_question.answer_options
  end

  def show
  end

  def new
    @answer_option = AnswerOption.new
  end

  def edit
  end

  def create
    @answer_option = AnswerOption.new(params[:answer_option])

    if @answer_option.save
      flash[:notice] = 'Answer option was successfully created.'
      redirect_to admin_content_area_exam_definition_exam_question_answer_options_path(@content_area, @exam_definition, @exam_question)
    else
      render :action => "new"
    end
  end

  def update
    if @answer_option.update_attributes(params[:answer_option])
      flash[:notice] = 'Answer option was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => "edit"
    end
  end

  def destroy
    @answer_option = @exam_question.answer_options.find(params[:id])
    @answer_option.destroy

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
    @exam_question = @exam_definition.exam_questions.find(params[:exam_question_id])
    add_breadcrumb @exam_question.question, admin_content_area_exam_definition_exam_question_path(@content_area, @exam_definition, @exam_question)
  end

  def set_answer_option
    @answer_option = @exam_question.answer_options.find(params[:id])
    add_breadcrumb @answer_option.answer
  end
end
