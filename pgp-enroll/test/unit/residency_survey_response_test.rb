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

  context 'with a ResidencySurveyResponse' do
    setup do
      @residency_survey_response = Factory.build(:residency_survey_response)
    end

    should_require_attributes :us_resident

    context 'for a US resident' do
      setup { @residency_survey_response.us_resident = true }

      context 'with a zip code' do
        setup { @residency_survey_response.zip = '12345' }

        should_require_attributes :can_travel_to_boston

        context 'who can travel to boston' do
          setup { @residency_survey_response.can_travel_to_boston = true }

          should_be_valid
          should_be_eligible
          should_not_have_waitlist_message
        end

        context 'who cannot travel to boston' do
          setup { @residency_survey_response.can_travel_to_boston = false }

          should_require_attributes :contact_when_boston_travel_facilitated

          context 'and wants to hear when Boston travel is facilitated' do
            setup do
              @residency_survey_response.contact_when_boston_travel_facilitated = true
            end

            should_be_valid
            should_not_be_eligible
            should_have_waitlist_message %r{will contact you when}i
          end

          context 'and does not want to know when Boston travel is facilitated' do
            setup do
              @residency_survey_response.contact_when_boston_travel_facilitated = false
            end

            should_be_valid
            should_not_be_eligible
            should_have_waitlist_message %r{thank you for your interest}i
          end
        end
      end
    end

    context 'for a non-US resident' do
      setup { @residency_survey_response.us_resident = false }

      should_not_be_eligible
      should_require_attributes :country

      context 'who specifies their country' do
        setup { @residency_survey_response.country = 'Canada' }

        should_require_attributes :contact_when_pgp_opens_outside_us

        context 'who wants to be contacted for international pgp' do
          setup { @residency_survey_response.contact_when_pgp_opens_outside_us = true }

          should_be_valid
          should_not_be_eligible
          should_have_waitlist_message %r{will contact you when}i
        end

        context 'who does not want to be contacted for international pgp' do
          setup { @residency_survey_response.contact_when_pgp_opens_outside_us = false }

          should_be_valid
          should_not_be_eligible
          should_have_waitlist_message %r{thank you for your interest}i
        end
      end
    end
  end

end
