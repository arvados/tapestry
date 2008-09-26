require 'test_helper'

class ExamVersionTest < ActiveSupport::TestCase
  context 'given an exam version' do
    setup do
      @exam_version = Factory :exam_version
    end

    should_belong_to :exam
    should_require_attributes :title, :description
    should_have_many :exam_questions
    should_have_many :exam_responses
  end

  context 'given an exam' do
    setup { @exam = Factory(:exam) }

    context 'when creating multiple versions' do
      setup do
        @versions = []
        3.times { @versions << Factory(:exam_version, :exam => @exam) }
      end

      should 'assign the next version to each' do
        assert_equal [1,2,3], @versions.map(&:version)
      end
    end
  end

  context 'given an exam with questions and answers' do
    setup do
      @exam_version = Factory(:exam_version)
      3.times do
        @question = Factory(:multiple_choice_exam_question, :exam_version => @exam_version)
        @answer   = Factory(:answer_option, :exam_question => @question, :correct => true)
        3.times do |i|
          @answer = Factory(:answer_option, :exam_question => @question, :correct => false)
        end
      end

      @exam_version_count = ExamVersion.count
      @answer_count       = AnswerOption.count
      @question_count     = ExamQuestion.count
    end

    context 'when sent #clone' do
      setup do
        @new_version = @exam_version.duplicate!
      end

      should 'duplicate the exam version' do
        assert_equal @exam_version_count+1, ExamVersion.count
      end

      should 'duplicate all the exam questions' do
        assert_equal @question_count+3, ExamQuestion.count
      end

      should 'duplicate all the answer options' do
        assert_equal @answer_count+12, AnswerOption.count
      end

      should 'have a new version number' do
        assert_equal @exam_version.version+1, @new_version.version
      end

    end
  end

end
