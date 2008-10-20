require 'test_helper'

class ExamQuestionTest < ActiveSupport::TestCase
  context 'with an ExamQuestion' do
    setup do
      @exam_question = Factory :exam_question
    end

    should_belong_to :exam_version
    should_have_many :answer_options
    should_have_many :question_responses

    context "with a kind that is not 'MULTIPLE_CHOICE' or 'CHECK_ALL'" do
      setup do
        assert_valid @exam_question
        @exam_question.kind = 'FILL_IN_THE_BLANK'
      end

      should "not be valid" do
        assert !@exam_question.valid?
      end
    end
  end

  context 'with many questions in an exam' do
    setup do
      # why does this test sometimes fail if these are not present?
      Exam.destroy_all
      ExamVersion.destroy_all
      ExamQuestion.destroy_all

      @exam_version = Factory :exam_version
      @exam_questions = []
      3.times { Factory(:exam_question, :exam_version => @exam_version) }
    end

    should 'give right answer for #next_question' do
      assert_equal @exam_version.exam_questions.last,
                   @exam_version.exam_questions.first.next_question.next_question
    end

    should 'give right answer for #last_in_exam?' do
      assert ! @exam_version.exam_questions.first.last_in_exam?
      assert @exam_version.exam_questions.last.last_in_exam?
    end
  end

  context 'with a multiple choice exam question' do
    setup do
      @question = Factory(:exam_question, :kind => 'MULTIPLE_CHOICE')
      5.times do |i|
        @answer_option = Factory(:answer_option, :exam_question => @question, :correct => i.zero?)
      end
    end

    should 'give the id of the correct answer_option when sent #correct_answer' do
      assert_equal @question.answer_options.first.id.to_s, @question.correct_answer
    end
  end

  context 'with a check all exam question' do
    setup do
      @question = Factory(:exam_question, :kind => 'CHECK_ALL')
      5.times do |i|
        @answer_option = Factory(:answer_option, :exam_question => @question)
        @answer_option.update_attribute(:correct, i.odd?)
      end

      @correct_answers = @question.answer_options.select(&:correct?)
    end

    should 'give the answer option ids joined by comma when sent #correct_answer' do
      assert_equal @correct_answers.map(&:id).join(','), @question.correct_answer
    end
  end

end
