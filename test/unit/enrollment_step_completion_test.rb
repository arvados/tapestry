require 'test_helper'

class EnrollmentStepCompletionTest < ActiveSupport::TestCase
  setup do
    @enrollment_step_completion = Factory :enrollment_step_completion
  end

  should validate_presence_of :user
  should validate_presence_of :enrollment_step
end
