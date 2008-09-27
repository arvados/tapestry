require 'test_helper'

class QuestionResponseTest < ActiveSupport::TestCase
  context 'with an QuestionResponse' do
    setup do
      @question_response = Factory :question_response
    end

    should_belong_to :exam_response
    should_belong_to :answer_option
  end

  context 'in response to a multiple choice question' do
    setup do
    end

    context 'with the correct answer' do
      setup do
      end

      should_eventually 'be correct' do
      end
    end

    context 'with the incorrect answer' do
      setup do
      end

      should_eventually 'not be correct' do
      end
    end
  end

  context 'in response to a check all question' do
    setup do
    end

    context 'with the correct answers' do
      setup do
      end

      should_eventually 'be correct' do
      end
    end

    context 'with some correct answers' do
      setup do
      end

      should_eventually 'not be correct' do
      end
    end

    context 'with no correct answers' do
      setup do
      end

      should_eventually 'not be correct' do
      end
    end
  end

end
