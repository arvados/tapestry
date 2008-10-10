require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  should_have_many :enrollment_step_completions
  should_have_many :completed_enrollment_steps
  should_have_many :exam_responses

  context 'a user' do
    setup do
      @password = 'zebras'
      @user = Factory(:user,
                      :first_name            => 'Jason',
                      :middle_name           => 'Paul',
                      :last_name             => 'Morrison',
                      :password              => @password,
                      :password_confirmation => @password)
    end

    should_require_attributes :first_name, :last_name, :email
    # should_allow_values_for ... maybe swap RESTful Auth for clearance,
    # so don't worry about this yet.

    should "return the full name when sent #full_name" do
      assert_equal "Jason Paul Morrison", @user.full_name
    end

    should "return a full name with correct spacing even if there are fewer than 3 names" do
      @user.stubs(:middle_name).returns('')
      assert_equal "Jason Morrison", @user.full_name

      @user.stubs(:last_name).returns('')
      assert_equal "Jason", @user.full_name
    end

    context 'when activated' do
      setup do
        @user.activate!
      end

      should "reset password" do
        @user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
        assert_equal @user, User.authenticate(@user.email, 'new password')
      end

      should "not rehash password" do
        @new_email = 'quentin2@example.com'
        @user.update_attributes(:email => @new_email)
        assert_equal @user, User.authenticate(@new_email, @password)
      end

      should "authenticate user" do
        assert_equal @user, User.authenticate(@user.email, @password)
      end

      should "set remember token" do
        @user.remember_me
        assert_not_nil @user.remember_token
        assert_not_nil @user.remember_token_expires_at
      end

      should "unset remember token" do
        @user.remember_me
        assert_not_nil @user.remember_token
        @user.forget_me
        assert_nil @user.remember_token
      end

      should "remember me for one week" do
        before = 1.week.from_now.utc
        @user.remember_me_for 1.week
        after = 1.week.from_now.utc
        assert_not_nil @user.remember_token
        assert_not_nil @user.remember_token_expires_at
        assert @user.remember_token_expires_at.between?(before, after)
      end

      should "remember me until one week" do
        time = 1.week.from_now.utc
        @user.remember_me_until time
        assert_not_nil @user.remember_token
        assert_not_nil @user.remember_token_expires_at
        assert_equal @user.remember_token_expires_at, time
      end

      should "remember me default two weeks" do
        before = 2.weeks.from_now.utc
        @user.remember_me
        after = 2.weeks.from_now.utc
        assert_not_nil @user.remember_token
        assert_not_nil @user.remember_token_expires_at
        assert @user.remember_token_expires_at.between?(before, after)
      end
    end
  end

  should "create user" do
    assert_difference 'User.count' do
      user = Factory(:user)
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  should "initialize activation code upon creation" do
    user = Factory(:user)
    user.reload
    assert_not_nil user.activation_code
  end

  context "partially complete enrollments" do
    setup do
      @user1, @user2, @user3 = Factory(:user), Factory(:user), Factory(:user)

      EnrollmentStep.delete_all
      @enrollment_steps = []
      5.times { @enrollment_steps << Factory(:enrollment_step) }

      # No EnrollmentStepCompletions for @user1
      3.times { |n| @user2.complete_enrollment_step @enrollment_steps[n] }
      5.times { |n| @user3.complete_enrollment_step @enrollment_steps[n] }
    end

    should "give the correct next step when #next_enrollment_step" do
      assert_equal @enrollment_steps[0], @user1.next_enrollment_step
      assert_equal @enrollment_steps[3], @user2.next_enrollment_step
    end

    should "give nil when #next_enrollment_step called and user has completed all EnrollmentSteps" do
      assert_nil @user3.next_enrollment_step
    end
  end

  should "add a completed_enrollment_step when sent #complete_enrollment_step" do
    user = Factory(:user)
    step = Factory(:enrollment_step)

    assert_difference 'user.completed_enrollment_steps.count' do
      user.complete_enrollment_step(step)
    end
  end

  should "add an enrollment_step_completion for enrollment_step(:signup) upon activation" do
    # User.activate! explicitly tries to complete the 'signup' enrollment_step
    Factory(:enrollment_step, :keyword => 'signup')
    user = Factory(:user)

    assert_difference 'user.completed_enrollment_steps.count' do
      user.activate!
    end
  end

  should_require_attributes :email, :password

  should "require password confirmation" do
    assert_no_difference 'User.count' do
      u = Factory.build(:user, :password_confirmation => nil)
      assert !u.valid?
      assert u.errors.on(:password_confirmation)
    end
  end

 should_eventually 'test last_completed_enrollment_step'

end
