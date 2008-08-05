require 'test_helper'

class ContentAreaTest < ActiveSupport::TestCase
  setup do
    @content_area = Factory :content_area
  end

  should_have_many :exam_definitions
  should_require_attributes :title, :description
end


