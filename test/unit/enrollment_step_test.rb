require 'test_helper'

class EnrollmentStepTest < ActiveSupport::TestCase
  setup do
    @enrollment_step = Factory :enrollment_step
  end

  should validate_presence_of :keyword
  should validate_presence_of :ordinal
  should validate_presence_of :title
  should validate_presence_of :description
  should have_many :enrollment_step_completions
  should have_many :completers
end
