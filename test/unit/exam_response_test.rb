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
      @exam_response.reload
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
          @exam_version.exam_questions.each_with_index do |question, i|
            @exam_response.question_responses.create({
              :exam_question => question,
              :answer        => i.zero? ? 'the-wrong-answer' : question.correct_answer
            })
          end
        end

        should 'not be correct' do
          assert !@exam_response.correct?
        end
      end

      context 'with no correct answers' do
        setup do
          @exam_version.exam_questions.each_with_index do |question, i|
            @exam_response.question_responses.create({
              :exam_question => question,
              :answer        => 'oh man this is so wrong'
            })
          end
        end

        should 'not be correct' do
          assert !@exam_response.correct?
        end
      end
    end
  end

  should "give the count of question_responses when sent response_count" do
    exam_response = Factory(:exam_response)
    5.times { Factory(:question_response, :exam_response => exam_response) }
    assert_equal 5, exam_response.response_count
  end

end
