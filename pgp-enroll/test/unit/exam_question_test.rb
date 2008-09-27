require 'test_helper'

class ExamQuestionTest < ActiveSupport::TestCase
  context 'with an ExamQuestion' do
    setup do
      @exam_question = Factory :exam_question
    end

    should_belong_to :exam_version
    should_have_many :answer_options

    context "with a kind that is not 'MULTIPLE_CHOICE' or 'CHECK_ALL'" do
      setup do
        assert_valid @exam_question
        @exam_question.kind = 'FILL_IN_THE_BLANK'
      end

      should "not be valid" do
        assert !@exam_question.valid?
      end
    end
  end

  context 'with many questions in an exam' do
    setup do
      @exam_version = Factory :exam_version
      @exam_questions = []
      3.times { Factory(:exam_question, :exam_version => @exam_version) }
    end

    should 'give right answer for #next_question' do
      assert_equal @exam_version.exam_questions.last,
                   @exam_version.exam_questions.first.next_question.next_question
    end

    should 'give right answer for #last_in_exam?' do
      assert ! @exam_version.exam_questions.first.last_in_exam?
      assert @exam_version.exam_questions.last.last_in_exam?
    end
  end
end
