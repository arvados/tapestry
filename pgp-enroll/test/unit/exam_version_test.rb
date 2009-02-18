require 'test_helper'

class ExamVersionTest < ActiveSupport::TestCase
  context 'given an exam version' do
    setup do
      @exam_version = Factory :exam_version
    end

    should_belong_to :exam
    should_validate_presence_of :title, :description, :ordinal
    should_have_many :exam_questions
    should_have_many :exam_responses

    context 'that is completed by a user' do
      setup do
        @user = Factory(:user)
        @response = Factory(:exam_response,
                            :exam_version => @exam_version,
                            :user => @user)
      end

      should 'return true when sent #completed_by?(user)' do
        assert @exam_version.completed_by?(@user)
      end
    end

    context 'that is not completed by a user' do
      setup do
        @user = Factory(:user)
      end

      should 'return false when sent #completed_by?(user)' do
        assert !@exam_version.completed_by?(@user)
      end
    end
  end

  context 'an exam version with no questions' do
    setup do
      @version = Factory(:exam_version)
    end

    context 'marking it as published' do
      setup do
        @version.published = true
      end

      should 'not be valid' do
        assert ! @version.valid?
      end
    end
  end

  context 'given a published exam version' do
    setup do
      @published = Factory(:exam_version)
      Factory(:exam_question, :exam_version => @published)
      @published.update_attributes({:published => true})
    end

    should 'show up in ExamVersion#published' do
      assert ExamVersion.published.include?(@published)
    end
  end

  context 'given an unpublished exam version' do
    setup do
      @unpublished = Factory(:exam_version, :published => false)
    end

    should 'not show up in ExamVersion#published' do
      assert !ExamVersion.published.include?(@unpublished)
    end
  end

  context 'given an exam' do
    setup { @exam = Factory(:exam) }

    context 'when creating multiple versions' do
      setup do
        @versions = []
        3.times { @versions << Factory(:exam_version, :exam => @exam) }
        @versions.shift.destroy
        @versions << Factory(:exam_version, :exam => @exam)
      end

      should 'assign the next version to each' do
        assert_equal [2,3,4], @versions.map(&:version)
      end
    end
  end

  context 'given an exam with questions and answers' do
    setup do
      @exam_version = Factory(:exam_version)
      3.times do
        @question = Factory(:exam_question, :exam_version => @exam_version)
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

  context 'with three exam_versions with versions' do
    setup do
      @exam = Factory(:exam)
      @v3 = Factory(:exam_version, :exam => @exam)
      @v2 = Factory(:exam_version, :exam => @exam)
      @v1 = Factory(:exam_version, :exam => @exam)

      @v1.update_attributes(:version => 1001)
      @v2.update_attributes(:version => 1002)
      @v3.update_attributes(:version => 1003)

      @v1.update_attributes(:version => 1)
      @v2.update_attributes(:version => 2)
      @v3.update_attributes(:version => 3)

      # default order by id
      assert_not_equal [@v1, @v2, @v3], @exam.versions
    end

    should 'order them by version on #by_version' do
      assert_equal [@v1, @v2, @v3].map(&:version), @exam.versions.by_version.map(&:version)
    end
  end


end
