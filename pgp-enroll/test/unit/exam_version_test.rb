require 'test_helper'

class ExamVersionTest < ActiveSupport::TestCase
  context 'given an exam version' do
    setup do
      @exam_version = Factory :exam_version
    end

    should_belong_to :exam
    should_require_attributes :title, :description, :version
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

end
