require 'test_helper'

class ContentAreaTest < ActiveSupport::TestCase
  setup do
    @content_area = Factory :content_area
  end

  should_have_many :exams
  should_require_attributes :title, :description
end


