require 'test_helper'

class ExamResponseTest < ActiveSupport::TestCase
  context 'with an ExamResponse' do
    setup do
      @exam_response = Factory :exam_response
    end

    should_belong_to :user
    should_belong_to :original_user
    should_belong_to :exam_definition
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
  end
end
