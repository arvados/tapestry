require 'test_helper'

class ExamDefinitionTest < ActiveSupport::TestCase
  setup do
    @exam_definition = Factory :exam_definition
  end
  should_belong_to :content_area
  should_require_attributes :title, :description
end
