require 'test_helper'

class EnrollmentStepTest < ActiveSupport::TestCase
  should_require_attributes :keyword, :ordinal, :title, :description

  should_have_many :enrollment_step_completions
  should_have_many :completers, :source => :users

  context "with some users and partially complete enrollments" do
    setup do
      @user1, @user2, @user3 = Factory(:user), Factory(:user), Factory(:user)

      @enrollment_steps = []
      5.times { @enrollment_steps << Factory(:enrollment_step) }

      # No EnrollmentStepCompletions for @user1
      3.times { |n| EnrollmentStepCompletion.create :enrollment_step => @enrollment_steps[n], :user => @user2 }
      5.times { |n| EnrollmentStepCompletion.create :enrollment_step => @enrollment_steps[n], :user => @user3 }
    end

    should "give the correct next step when EnrollmentStep#next_for called" do
      assert_equal @enrollment_steps[0], EnrollmentStep.next_for(@user1)
      assert_equal @enrollment_steps[3], EnrollmentStep.next_for(@user2)
    end

    should "give nil when EnrollmentStep#next_for called and user has completed all EnrollmentSteps" do
      assert_nil EnrollmentStep.next_for(@user3)
    end
  end
end
