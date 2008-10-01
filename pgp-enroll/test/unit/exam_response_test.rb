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
      assert original_user_id = @exam_response.user.id
      @exam_response.discard_for_retake!
      assert_equal original_user_id, @exam_response.original_user_id
      assert_nil @exam_response.user
    end

    context 'in response to an exam' do
      setup do
        @exam_version = build_exam_version_with_questions_and_answers
        @exam_response = Factory(:exam_response, :exam_version => @exam_version)
      end

      context 'with all correct answers' do
        setup do
          # TODO: QuestionResponse is now configured differently...
          # @exam_version.exam_questions.each do |question|
          #   @exam_response.question_responses.create({
          #     :exam_version => @exam_version,
          #     :answer_option => question.correct_answer
          #   })
          # end
          @exam_version.exam_questions.each do |question|
            @exam_response.question_responses.create({
              :exam_question => question,
              :answer        => question.correct_answer
            })
          end
        end

        should 'be correct' do
          assert @exam_response.correct?
        end
      end

      context 'with some correct answers' do
        setup do
          #TODO setup
        end

        should 'not be correct' do
          assert !@exam_response.correct?
        end
      end

      context 'with no correct answers' do
        setup do
        end

        should 'not be correct' do
          assert !@exam_response.correct?
        end
      end
    end
  end

  def build_exam_version_with_questions_and_answers
    exam_version = Factory(:exam_version)
    5.times do
      question = Factory(:exam_question, :exam_version => exam_version)
      5.times do |i|
        answer_option = Factory(:answer_option, :exam_question => question, :correct => i.zero?)
      end
    end
    exam_version
  end

end
