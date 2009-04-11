require 'test_helper'

class EnrollmentStepTest < ActiveSupport::TestCase
  setup do
    @enrollment_step = Factory :enrollment_step
  end

  should_validate_presence_of :keyword, :ordinal, :title, :description
  should_have_many :enrollment_step_completions
  should_have_many :completers
end
