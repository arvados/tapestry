require 'test_helper'

class ExamDefinitionTest < ActiveSupport::TestCase
  context 'with some exams' do
    setup do
      @exam_definition = Factory :exam_definition
      @exam1 = Factory(:exam_definition)
      @exam2 = Factory(:exam_definition, :parent => @exam1)
    end

    should_belong_to :content_area
    should_require_attributes :title, :description
    should_have_many :exam_questions
    should_have_many :exam_responses

    should 'show version when sent #version' do
      assert_equal 1, @exam1.version
      assert_equal 2, @exam2.version
    end
  end
end
