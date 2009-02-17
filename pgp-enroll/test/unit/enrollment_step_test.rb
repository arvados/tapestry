require 'test_helper'

class EnrollmentStepTest < ActiveSupport::TestCase
  setup do
    @enrollment_step = Factory :enrollment_step
  end

  should_require_attributes :keyword, :ordinal, :title, :description
  should_have_many :enrollment_step_completions
  should_allow_values_for :phase, 'screening', 'preenrollment'
  should_have_many :completers

  context 'with enrollment steps for different phases' do
    setup do
      EnrollmentStep.delete_all
      @screening_steps = [
        Factory(:enrollment_step, :phase => 'screening'),
        Factory(:enrollment_step, :phase => 'screening')
      ]
      @preenrollment_steps = [
        Factory(:enrollment_step, :phase => 'preenrollment'),
        Factory(:enrollment_step, :phase => 'preenrollment')
      ]
    end

    should 'return the steps for the right phase when sent .phase_for' do
      assert_equal @screening_steps, EnrollmentStep.for_phase('screening')
      assert_equal @preenrollment_steps, EnrollmentStep.for_phase('preenrollment')
    end
  end
end
