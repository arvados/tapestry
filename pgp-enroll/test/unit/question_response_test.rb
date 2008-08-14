require 'test_helper'

class QuestionResponseTest < ActiveSupport::TestCase
  context 'with an QuestionResponse' do
    setup do
      @question_response = Factory :question_response
    end

    should_belong_to :exam_response
    should_belong_to :answer_option
  end
end
