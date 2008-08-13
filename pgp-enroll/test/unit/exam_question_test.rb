require 'test_helper'

class ExamQuestionTest < ActiveSupport::TestCase
  context 'with an ExamQuestion' do
    setup do
      @exam_question = Factory :exam_question
    end

    should_belong_to :exam_definition
  end
end
