class Admin::ExamQuestionsController < Admin::AdminControllerBase
  add_breadcrumb 'Content Areas', '/admin/content_areas'
  before_filter :set_content_area
  before_filter :set_exam
  before_filter :set_exam_version
  before_filter :set_exam_question, :only => [:show, :edit, :update]

  def index
    @exam_questions = @exam_version.exam_questions.ordered
  end

  def show
    @answer_options = @exam_question.answer_options

    @all = QuestionResponse.find_all_by_exam_question_id(@exam_question.id).count
    @correct = QuestionResponse.correct.find_all_by_exam_question_id(@exam_question.id).count
    @incorrect = QuestionResponse.incorrect.find_all_by_exam_question_id(@exam_question.id).count

    if @all > 0 then
      @incorrect_percent = sprintf("%.02f\%",QuestionResponse.incorrect.find_all_by_exam_question_id(@exam_question.id).count.to_f / QuestionResponse.find_all_by_exam_question_id(@exam_question.id).count.to_f * 100)
      @correct_percent = sprintf("%.02f\%",QuestionResponse.correct.find_all_by_exam_question_id(@exam_question.id).count.to_f / QuestionResponse.find_all_by_exam_question_id(@exam_question.id).count.to_f * 100)
    else
      @incorrect_percent = ''
      @correct_percent = ''
    end

  end

  def new
    @exam_question = @exam_version.exam_questions.new(:ordinal => @exam_version.exam_questions.count + 1)
  end

  def edit
  end

  def create
    @exam_question = @exam_version.exam_questions.new(params[:exam_question])
    @exam_question.kind = params[:exam_question][:kind]

    if @exam_question.save
      flash[:notice] = 'Question was successfully created.'
      redirect_to admin_content_area_exam_exam_version_exam_questions_path(@content_area, @exam, @exam_version)
    else
      render :action => "new"
    end
  end

  def update
    if @exam_question.update_attributes(params[:exam_question])
      flash[:notice] = 'Question was successfully updated.'
      redirect_to admin_content_area_exam_exam_version_exam_questions_url(@content_area, @exam, @exam_version)
    else
      render :action => "edit"
    end
  end

  def destroy
    @exam_question = @exam_version.exam_questions.find(params[:id])
    @exam_question.destroy

    redirect_to admin_content_area_exam_exam_version_exam_questions_url(@content_area, @exam, @exam_version)
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
    @exam_version = @exam.versions.find params[:exam_version_id]
    add_breadcrumb "Version #{@exam_version.version}", admin_content_area_exam_exam_version_path(@content_area, @exam, @exam_version)
  end

  def set_exam_question
    @exam_question = @exam_version.exam_questions.find(params[:id])
    add_breadcrumb @exam_question.question
  end
end
