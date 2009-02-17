require 'test_helper'

class PhaseCompletionTest < ActiveSupport::TestCase
  should_belong_to :user

  should_allow_values_for :phase, 'screening', 'preenrollment'
  should_not_allow_values_for :phase, '', 'asdf'

  context 'when a user' do
    setup do
      @user = Factory(:user)
    end

    context 'has no phase completions' do
      setup do
        assert_equal 0, @user.phase_completions.size
      end

      should 'return screening when sent phase_for' do
        assert_equal 'screening', PhaseCompletion.phase_for(@user)
      end
    end

    context 'has completed the screening phase' do
      setup do
        Factory(:phase_completion, :user => @user, :phase => 'screening')
      end

      should 'return preenrollment when sent phase_for' do
        assert_equal 'preenrollment', PhaseCompletion.phase_for(@user)
      end
    end
  end
end
