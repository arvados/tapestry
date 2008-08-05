require 'test_helper'

class ContentAreaTest < ActiveSupport::TestCase
  should_have_many :exam_definitions
  should_require_attributes :title, :description
end


