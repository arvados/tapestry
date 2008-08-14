require 'test_helper'

class AnswerOptionTest < ActiveSupport::TestCase
  context 'with an AnswerOption' do
    setup do
      @answer_option = Factory :answer_option
    end

    should_belong_to :exam_question
    should_have_many :question_responses
  end
end
