require 'test_helper'

class ExamQuestionTest < ActiveSupport::TestCase
  context 'with a MultipleChoiceExamQuestion' do
    setup do
      @exam_question = Factory :multiple_choice_exam_question
    end

    should_belong_to :exam_definition
    should_have_many :answer_options
  end

  context 'with many questions in an exam' do
    setup do
      @exam_definition = Factory :exam_definition
      @exam_questions = []
      3.times { Factory(:multiple_choice_exam_question, :exam_definition => @exam_definition) }
    end

    should 'give right answer for #next_question' do
      assert_equal @exam_definition.exam_questions.last,
                   @exam_definition.exam_questions.first.next_question.next_question
    end

    should 'give right answer for #last_in_exam?' do
      assert ! @exam_definition.exam_questions.first.last_in_exam?
      assert @exam_definition.exam_questions.last.last_in_exam?
    end
  end
end
