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
end
