require 'test_helper'

class EnrollmentStepCompletionTest < ActiveSupport::TestCase
  setup do
    @enrollment_step_completion = Factory :enrollment_step_completion
  end

  should_validate_presence_of :user, :enrollment_step
end
