require 'test_helper'

class EnrollmentStepTest < ActiveSupport::TestCase
  should_require_attributes :keyword, :ordinal, :title, :description
end
