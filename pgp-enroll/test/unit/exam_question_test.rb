require 'test_helper'

class ExamQuestionTest < ActiveSupport::TestCase
  context 'with a MultipleChoiceExamQuestion' do
    setup do
      @exam_question = Factory :multiple_choice_exam_question
    end

    should_belong_to :exam_version
    should_have_many :answer_options
  end

  context 'with many questions in an exam' do
    setup do
      @exam_version = Factory :exam_version
      @exam_questions = []
      3.times { Factory(:multiple_choice_exam_question, :exam_version => @exam_version) }
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
end
