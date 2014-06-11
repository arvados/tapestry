require 'test_helper'

class ResidencySurveyResponseTest < ActiveSupport::TestCase

  def self.should_be_valid
    should 'be valid' do
      assert @residency_survey_response.valid?, @residency_survey_response.errors.inspect
    end
  end

  def self.should_be_eligible
    should 'be eligible' do
      assert @residency_survey_response.eligible?
    end
  end

  def self.should_not_be_eligible
    should 'not be eligible' do
      assert ! @residency_survey_response.eligible?
    end
  end

  def self.should_have_waitlist_message(regex)
    should 'have a waitlist message' do
      assert_match regex, @residency_survey_response.waitlist_message
    end
  end

  def self.should_not_have_waitlist_message
    should 'not have a waitlist message' do
      assert_nil @residency_survey_response.waitlist_message
    end
  end

  context 'an ineligible response' do
    setup { @residency_survey_response = Factory(:ineligible_residency_survey_response) }
    should_not_be_eligible
  end

  context 'with a ResidencySurveyResponse' do
    setup do
      @residency_survey_response = Factory.build(:residency_survey_response)
    end

    should_be_eligible
    should_validate_presence_of :resident
    should_not_allow_mass_assignment_of :user_id

    context 'for a US resident' do
      setup { @residency_survey_response.resident = true }

      should 'require the zip code to be 5 digits long' do
        @residency_survey_response.zip = '1234'
        assert ! @residency_survey_response.valid?
        assert @residency_survey_response.errors[:zip]
      end

      should 'require the zip code to be numerical digits' do
        @residency_survey_response.zip = 'abcde'
        assert ! @residency_survey_response.valid?
        assert @residency_survey_response.errors[:zip]
      end

      context 'with a zip code' do
        setup { @residency_survey_response.zip = '12345' }

        should_validate_presence_of :can_travel_to_pgphq

        context 'who can travel to PGP HQ' do
          setup { @residency_survey_response.can_travel_to_pgphq = true }

          should_be_valid
          should_be_eligible
          should_not_have_waitlist_message
        end

        context 'who cannot travel to PGP HQ' do
          setup { @residency_survey_response.can_travel_to_pgphq = false }

          should_be_valid
          should_not_be_eligible
          should_have_waitlist_message %r{thank you for your interest}i
        end
      end
    end

    context 'for a non-US resident' do
      setup { @residency_survey_response.resident = false }

      should_not_be_eligible
      should_validate_presence_of :country

      context 'who specifies their country' do
        setup { @residency_survey_response.country = 'Canada' }

        should 'allow a blank zip code' do
          assert @residency_survey_response.valid?
          @residency_survey_response.zip = ''
          assert @residency_survey_response.valid?
        end

        should_be_valid
        should_not_be_eligible
        should_have_waitlist_message %r{thank you for your interest}i
      end
    end
  end

end
