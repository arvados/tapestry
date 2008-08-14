require 'test_helper'

class ExamQuestionTest < ActiveSupport::TestCase
  context 'with a MultipleChoiceExamQuestion' do
    setup do
      @exam_question = Factory :multiple_choice_exam_question
    end

    should_belong_to :exam_definition
  end
end
