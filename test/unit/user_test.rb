require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many :enrollment_step_completions
  should have_many :completed_enrollment_steps
  should have_many :exam_responses
  should have_many :waitlists
  should have_many :distinctive_traits
  should have_one  :residency_survey_response
  should have_one  :family_survey_response
  should have_one  :privacy_survey_response
  should have_one  :informed_consent_response
  should have_one  :baseline_traits_survey

  should allow_mass_assignment_of :email
  should allow_mass_assignment_of :email_confirmation
  should allow_mass_assignment_of :password
  should allow_mass_assignment_of :password_confirmation
  should allow_mass_assignment_of :first_name
  should allow_mass_assignment_of :middle_name
  should allow_mass_assignment_of :last_name
  should allow_mass_assignment_of :address1
  should allow_mass_assignment_of :address2
  should allow_mass_assignment_of :city
  should allow_mass_assignment_of :state
  should allow_mass_assignment_of :zip
  should allow_mass_assignment_of :phr_profile_name
  
# FIXME: this macro should be provided by paperclip, but for some reason it's not being picked up.
#  should_have_attached_file :phr

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

    should validate_presence_of :first_name
    should validate_presence_of :last_name
    should validate_presence_of :email
    # should_allow_values_for ... maybe swap RESTful Auth for clearance,
    # so don't worry about this yet.
    should_allow_values_for :email, 'a@b.cc', 'test@harvard.edu', 'jason.p.morrison@gmail.com'
    should_not_allow_values_for :email, 'aaa@bbb', 'aaa.com', 'a.b.com', 'aa@bb@cc', :message => /look like/
    should_not_allow_values_for :email, 'a@b.c', :message => /too short/
    should_not_allow_values_for :email, '', :message => /blank/


    should "require password validation on create" do
      user = User.new(:password => "blah", :password_confirmation => "boogidy")
      assert !user.save
      assert user.errors[:password].any? { |e| e =~ /confirmation/i }
    end

    # temporarily removed requirement
    #
    # should "require email validation on create" do
    #   user = User.new(:email => "blah", :email_confirmation => "boogidy")
    #   assert !user.save
    #   assert user.errors.on(:email).any? { |e| e =~ /confirmation/i }
    # end

    should "return the full name when sent #full_name" do
      assert_equal "Jason Paul Morrison", @user.full_name
    end

    should "return a full name with correct spacing even if there are fewer than 3 names" do
      @user.stubs(:middle_name).returns('')
      assert_equal "Jason Morrison", @user.full_name

      @user.stubs(:last_name).returns('')
      assert_equal "Jason", @user.full_name
    end

    context 'that is correct except for first_name' do
      setup do
        assert @user.valid?
        @user.first_name = nil
      end

      should 'be valid for other attrs' do
        assert @user.valid_for_attrs?(%w(last_name email))
      end

      should 'not be valid for first_name' do
        assert ! @user.valid_for_attrs?(['first_name'])
      end
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

    should "promote to the next enrollment step when sent #promote!" do
      EnrollmentStep.delete_all
      es1 = Factory(:enrollment_step, :keyword => 'first', :ordinal => 1)
      es2 = Factory(:enrollment_step, :keyword => 'second', :ordinal => 2)
      es3 = Factory(:enrollment_step, :keyword => 'third', :ordinal => 3)

      user = Factory(:user)

      user.promote!
      user.reload
      assert_equal es2, user.next_enrollment_step

      user.promote!
      user.reload
      assert_equal es3, user.next_enrollment_step
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

  context "has completed an enrollment step" do
    setup do
      @user = Factory(:user)
      @step = Factory(:enrollment_step)
      @user.complete_enrollment_step(@step)
      @user.reload
    end

    should "return true for #has_completed?(keyword)" do
      assert @user.has_completed?(@step.keyword)
    end

    should "return true for #has_completed?(another keyword)" do
      assert ! @user.has_completed?('nonexistant_step')
    end
  end

  should "not add two enrollment_steps if #complete_enrollment_step is called twice for the same step" do
    user = Factory(:user)
    step = Factory(:enrollment_step)

    assert_difference 'user.completed_enrollment_steps.count' do
      user.complete_enrollment_step(step)
    end

    assert_no_difference 'user.completed_enrollment_steps.count' do
      user.complete_enrollment_step(step)
    end
  end

  should "add an enrollment_step_completion for enrollment_step(:signup) upon activation" do
    user = Factory(:user)

    assert_difference 'user.completed_enrollment_steps.count' do
      user.activate!
    end
  end

  should validate_presence_of :email
  should validate_presence_of :password

  should "require password confirmation" do
    assert_no_difference 'User.count' do
      u = Factory.build(:user, :password_confirmation => nil)
      assert !u.valid?
      assert u.errors[:password_confirmation]
    end
  end

  should_eventually 'test last_completed_enrollment_step'

  context 'where some, but not all, users have completed the enrollment exam' do
    setup do
      assert @exams_step = EnrollmentStep.find_by_keyword('content_areas')
      @completed_users = [Factory(:user)]
      @uncompleted_users = [Factory(:user)]
      @completed_users.each { |u| Factory(:enrollment_step_completion, :enrollment_step => @exams_step, :user => u) }
    end

    should 'return all users who have completed the enrollment exam on User#has_completed("content_areas")' do
      User.has_completed("content_areas").each do |user|
        assert user.completed_enrollment_steps.include?(@exams_step)
      end
    end
  end

  should "strip whitespace on email when setting" do
    user = Factory(:user, :email => " test@example.com ")
    assert_equal "test@example.com", user.reload.email
  end

  should "strip whitespace on email when authenticating" do
    user = Factory(:activated_user, :email => "a@b.com", :password => "password", :password_confirmation => "password")
    assert_equal user, User.authenticate(" a@b.com ", "password")
  end

  should "only return inactive users for named scope .inactive" do
    inactive_user  = Factory(:user,           :first_name => "Ralph")
    activated_user = Factory(:activated_user, :first_name => "Lauren")

    assert_equal [inactive_user], User.inactive
  end

  context "with users who fall into various screening eligibility groups" do
    setup do
      User.delete_all
      assert eligibility_step = EnrollmentStep.find_by_keyword('screening_submission')
      assert promotion_step     = EnrollmentStep.find_by_keyword('eligibility_screening_results')

      @user1a = Factory(:user, :first_name => 'user1a')
      @user1a.complete_enrollment_step(eligibility_step)
      Factory(:residency_survey_response, :user => @user1a, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @user1a, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @user1a, :worrisome_information_comfort_level => 'always',
                                                            :information_disclosure_comfort_level => 'comfortable',
                                                            :past_genetic_test_participation  => 'public')
      @user1b = Factory(:user, :first_name => 'user1b')
      @user1b.complete_enrollment_step(eligibility_step)
      Factory(:residency_survey_response, :user => @user1b, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @user1b, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @user1b, :worrisome_information_comfort_level => 'understand',
                                                            :information_disclosure_comfort_level => 'understand',
                                                            :past_genetic_test_participation  => 'yes')
      @user1c = Factory(:user, :first_name => 'user1c')
      @user1c.complete_enrollment_step(eligibility_step)
      Factory(:residency_survey_response, :user => @user1c, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @user1c, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @user1c, :worrisome_information_comfort_level => 'always',
                                                            :information_disclosure_comfort_level => 'comfortable',
                                                            :past_genetic_test_participation  => 'no')
      @user1d = Factory(:user, :first_name => 'user1d')
      @user1d.complete_enrollment_step(eligibility_step)
      Factory(:residency_survey_response, :user => @user1d, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @user1d, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @user1d, :worrisome_information_comfort_level => 'always',
                                                            :information_disclosure_comfort_level => 'comfortable',
                                                            :past_genetic_test_participation  => 'unsure')

      @user2a = Factory(:user, :first_name => 'user2a')
      @user2a.complete_enrollment_step(eligibility_step)
      Factory(:residency_survey_response, :user => @user2a, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @user2a, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @user2a, :worrisome_information_comfort_level => 'depends',
                                                            :information_disclosure_comfort_level => 'depends',
                                                            :past_genetic_test_participation  => 'confidential')

      @user2b = Factory(:user, :first_name => 'user2b')
      @user2b.complete_enrollment_step(eligibility_step)
      Factory(:residency_survey_response, :user => @user2b, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @user2b, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @user2b, :worrisome_information_comfort_level => 'uncomfortable',
                                                            :information_disclosure_comfort_level => 'uncomfortable',
                                                            :past_genetic_test_participation  => 'confidential')

      @user2c = Factory(:user, :first_name => 'user2c')
      @user2c.complete_enrollment_step(eligibility_step)
      Factory(:residency_survey_response, :user => @user2c, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @user2c, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @user2c, :worrisome_information_comfort_level => 'uncomfortable',
                                                            :information_disclosure_comfort_level => 'unsure',
                                                            :past_genetic_test_participation  => 'confidential')

      @user2d = Factory(:user, :first_name => 'user2d')
      @user2d.complete_enrollment_step(eligibility_step)
      Factory(:residency_survey_response, :user => @user2d, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @user2d, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @user2d, :worrisome_information_comfort_level => 'depends',
                                                            :information_disclosure_comfort_level => 'comfortable',
                                                            :past_genetic_test_participation  => 'confidential')

      @user3a = Factory(:user, :first_name => 'user3a')
      @user3a.complete_enrollment_step(eligibility_step)
      Factory(:residency_survey_response, :user => @user3a, :us_resident => false, :country => "France")
      Factory(:family_survey_response, :user => @user3a)
      Factory(:privacy_survey_response, :user => @user3a)

      @user3b = Factory(:user, :first_name => 'user3b')
      @user3b.complete_enrollment_step(eligibility_step)
      Factory(:residency_survey_response, :user => @user3b, :can_travel_to_boston => false)
      Factory(:family_survey_response, :user => @user3b)
      Factory(:privacy_survey_response, :user => @user3b)

      @user3c = Factory(:user, :first_name => 'user3c')
      @user3c.complete_enrollment_step(eligibility_step)
      Factory(:family_survey_response, :user => @user3c, :monozygotic_twin => 'unwilling')
      Factory(:residency_survey_response, :user => @user3c)
      Factory(:privacy_survey_response, :user => @user3c)

      @user3d = Factory(:user, :first_name => 'user3d')
      @user3d.complete_enrollment_step(eligibility_step)
      Factory(:family_survey_response, :user => @user3d, :birth_year => Time.now.year - 15)
      Factory(:residency_survey_response, :user => @user3d)
      Factory(:privacy_survey_response, :user => @user3d)

      @user3e = Factory(:user, :first_name => 'user3e')
      @user3e.complete_enrollment_step(eligibility_step)
      Factory(:family_survey_response, :user => @user3e, :monozygotic_twin => 'unknown')
      Factory(:residency_survey_response, :user => @user3e)
      Factory(:privacy_survey_response, :user => @user3e)

      @no_entrance_exam = Factory(:user, :first_name => 'no_entrance_exam')
      Factory(:residency_survey_response, :user => @no_entrance_exam, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @no_entrance_exam, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @no_entrance_exam, :worrisome_information_comfort_level => 'depends',
                                                            :information_disclosure_comfort_level => 'comfortable',
                                                            :past_genetic_test_participation  => 'confidential')

      @waitlisted_user = Factory(:user, :first_name => 'waitlisted_user')
      @waitlisted_user.complete_enrollment_step(eligibility_step)
      Factory(:waitlist, :user => @waitlisted_user)
      Factory(:residency_survey_response, :user => @waitlisted_user, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @waitlisted_user, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @waitlisted_user, :worrisome_information_comfort_level => 'always',
                                                            :information_disclosure_comfort_level => 'comfortable',
                                                            :past_genetic_test_participation  => 'unsure')

      @resubmitted_waitlisted_user = Factory(:user, :first_name => 'resubmitted_waitlisted_user')
      @resubmitted_waitlisted_user.complete_enrollment_step(eligibility_step)
      Factory(:waitlist, :user => @resubmitted_waitlisted_user, :resubmitted_at => Time.now)
      Factory(:residency_survey_response, :user => @resubmitted_waitlisted_user, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @resubmitted_waitlisted_user, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @resubmitted_waitlisted_user, :worrisome_information_comfort_level => 'always',
                                                            :information_disclosure_comfort_level => 'comfortable',
                                                            :past_genetic_test_participation  => 'unsure')

      @promoted_user = Factory(:user, :first_name => 'promoted_user')
      @promoted_user.complete_enrollment_step(eligibility_step)
      @promoted_user.complete_enrollment_step(promotion_step)
      Factory(:residency_survey_response, :user => @promoted_user, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @promoted_user, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @promoted_user, :worrisome_information_comfort_level => 'always',
                                                            :information_disclosure_comfort_level => 'comfortable',
                                                            :past_genetic_test_participation  => 'unsure')

      @waitlisted_user2 = Factory(:user, :first_name => 'waitlisted_user2')
      @waitlisted_user2.complete_enrollment_step(eligibility_step)
      Factory(:waitlist, :user => @waitlisted_user2)
      Factory(:residency_survey_response, :user => @waitlisted_user2, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @waitlisted_user2, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @waitlisted_user2, :worrisome_information_comfort_level => 'depends',
                                                            :information_disclosure_comfort_level => 'comfortable',
                                                            :past_genetic_test_participation  => 'confidential')

      @resubmitted_waitlisted_user2 = Factory(:user, :first_name => 'resubmitted_waitlisted_user2')
      @resubmitted_waitlisted_user2.complete_enrollment_step(eligibility_step)
      Factory(:waitlist, :user => @resubmitted_waitlisted_user2, :resubmitted_at => Time.now)
      Factory(:residency_survey_response, :user => @resubmitted_waitlisted_user2, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @resubmitted_waitlisted_user2, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @resubmitted_waitlisted_user2, :worrisome_information_comfort_level => 'depends',
                                                            :information_disclosure_comfort_level => 'comfortable',
                                                            :past_genetic_test_participation  => 'confidential')

      @promoted_user2 = Factory(:user, :first_name => 'promoted_user2')
      @promoted_user2.complete_enrollment_step(eligibility_step)
      @promoted_user2.complete_enrollment_step(promotion_step)
      Factory(:residency_survey_response, :user => @promoted_user2, :us_resident => true, :can_travel_to_boston => true)
      Factory(:family_survey_response,    :user => @promoted_user2, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      Factory(:privacy_survey_response,   :user => @promoted_user2, :worrisome_information_comfort_level => 'depends',
                                                            :information_disclosure_comfort_level => 'comfortable',
                                                            :past_genetic_test_participation  => 'confidential')

      @waitlisted_user3 = Factory(:user, :first_name => 'waitlisted_user3')
      @waitlisted_user3.complete_enrollment_step(eligibility_step)
      Factory(:family_survey_response, :user => @waitlisted_user3, :monozygotic_twin => 'unknown')
      Factory(:residency_survey_response, :user => @waitlisted_user3)
      Factory(:privacy_survey_response, :user => @waitlisted_user3)
      Factory(:waitlist, :user => @waitlisted_user3)

      @resubmitted_waitlisted_user3 = Factory(:user, :first_name => 'resubmitted_waitlisted_user3')
      @resubmitted_waitlisted_user3.complete_enrollment_step(eligibility_step)
      Factory(:family_survey_response, :user => @resubmitted_waitlisted_user3, :monozygotic_twin => 'unknown')
      Factory(:residency_survey_response, :user => @resubmitted_waitlisted_user3)
      Factory(:privacy_survey_response, :user => @resubmitted_waitlisted_user3)
      Factory(:waitlist, :user => @resubmitted_waitlisted_user3, :resubmitted_at => Time.now)
    end

    should "return ids of users promoted sent .promoted_ids" do
      assert_equal [@promoted_user, @promoted_user2].map(&:id).map(&:to_s).sort, User.promoted_ids.sort
    end

    should "return ids of users waitlisted sent .waitlisted_ids" do
      assert_equal [@waitlisted_user, @waitlisted_user2, @waitlisted_user3].map(&:id).map(&:to_s).sort, User.waitlisted_ids.sort
    end

    should "returns users in eligibility group 1 when sent .in_screening_eligibility_group(1)" do
      assert_equal [@user1a, @user1b, @user1c, @user1d, @resubmitted_waitlisted_user].map(&:first_name).sort, User.in_screening_eligibility_group(1).map(&:first_name).sort
    end

    should "returns users in eligibility group 2 when sent .in_screening_eligibility_group(2)" do
      assert_equal [@user2a, @user2b, @user2c, @user2d, @resubmitted_waitlisted_user2].map(&:first_name).sort, User.in_screening_eligibility_group(2).map(&:first_name).sort
    end

    should "returns users in eligibility group 3 when sent .in_screening_eligibility_group(3)" do
      assert_equal [@user3a, @user3b, @user3c, @user3d, @user3e, @resubmitted_waitlisted_user3].map(&:first_name).sort, User.in_screening_eligibility_group(3).map(&:first_name).sort
    end
  end

  should "properly calculate last_waitlisted_at" do
    assert_nil Factory(:user).last_waitlisted_at

    user = Factory(:user)
    later = Factory(:waitlist, :user => user, :created_at => 1.day.ago)
    earlier = Factory(:waitlist, :user => user, :created_at => 2.days.ago)

    assert_equal later.created_at.day, user.reload.last_waitlisted_at.day
  end

end
