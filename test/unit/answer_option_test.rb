require 'test_helper'

class AnswerOptionTest < ActiveSupport::TestCase
  context 'with an AnswerOption' do
    setup do
      @answer_option = Factory :answer_option
    end

    should belong_to :exam_question
  end
end
