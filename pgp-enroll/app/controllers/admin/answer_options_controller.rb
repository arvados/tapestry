class Admin::AnswerOptionsController < Admin::AdminControllerBase
  add_breadcrumb 'Content Areas', '/admin/content_areas'
  before_filter :set_content_area
  before_filter :set_exam
  before_filter :set_exam_version
  before_filter :set_exam_question
  before_filter :set_answer_option, :only => [:show, :edit, :update, :destroy]

  def index
    @answer_options = @exam_question.answer_options
  end

  def show
  end

  def new
    @answer_option = @exam_question.answer_options.new
  end

  def edit
  end

  def create
    @answer_option = @exam_question.answer_options.new(params[:answer_option])

    if @answer_option.save
      flash[:notice] = 'Answer option was successfully created.'
      redirect_to admin_content_area_exam_exam_version_exam_question_answer_options_path(@content_area, @exam, @exam_version, @exam_question)
    else
      render :action => "new"
    end
  end

  def update
    if @answer_option.update_attributes(params[:answer_option])
      flash[:notice] = 'Answer option was successfully updated.'
      redirect_to admin_content_area_exam_exam_version_exam_question_answer_options_path(@content_area, @exam, @exam_version, @exam_question)
    else
      render :action => "edit"
    end
  end

  def destroy
    @answer_option.destroy

    redirect_to admin_content_area_exam_exam_version_exam_question_answer_options_path(@content_area, @exam, @exam_version, @exam_question)
  end

  private

  def set_content_area
    @content_area = ContentArea.find params[:content_area_id]
    add_breadcrumb @content_area.title, admin_content_area_path(@content_area)
  end

  def set_exam
    @exam = @content_area.exams.find(params[:exam_id])
    add_breadcrumb @exam.title, admin_content_area_exam_path(@content_area, @exam)
  end

  def set_exam_version
    @exam_version = @exam.versions.find(params[:exam_version_id])
    add_breadcrumb "Version #{@exam_version.version}", admin_content_area_exam_exam_version_path(@content_area, @exam, @exam_version)
  end

  def set_exam_question
    @exam_question = @exam_version.exam_questions.find(params[:exam_question_id])
    add_breadcrumb @exam_question.question, admin_content_area_exam_exam_version_exam_question_path(@content_area, @exam, @exam_version, @exam_question)
  end

  def set_answer_option
    @answer_option = @exam_question.answer_options.find(params[:id])
    add_breadcrumb @answer_option.answer
  end
end
