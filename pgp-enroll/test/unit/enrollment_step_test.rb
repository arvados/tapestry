require 'test_helper'

class EnrollmentStepTest < ActiveSupport::TestCase
  should_require_attributes :keyword, :order, :title, :description
end
