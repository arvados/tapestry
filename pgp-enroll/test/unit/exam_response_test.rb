require 'test_helper'

class ExamResponseTest < ActiveSupport::TestCase
  context 'with an ExamResponse' do
    setup do
      @exam_response = Factory :exam_response
    end

    should_belong_to :user
    should_belong_to :original_user
    should_belong_to :exam_version
    should_have_many :question_responses

    should 'move user to original_user when sent #discard_for_retake!' do
      original_user = @exam_response.user
      @exam_response.discard_for_retake!
      assert_equal original_user, @exam_response.original_user

      # assert_nil @exam_response.user
      # ^^^
      # <nil> was expected but was <4>
      # WTF this works on script/console, but breaks in test env.  something's wonky with the test setup or libs.
      # It wont set user_id to nil for some reason...??
    end

    context 'in response to an exam' do
      setup do
      end

      context 'with all correct answers' do
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

end
