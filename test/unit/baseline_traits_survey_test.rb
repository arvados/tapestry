require 'test_helper'

class BaselineTraitsSurveyTest < ActiveSupport::TestCase
  should belong_to :user
  should validate_presence_of :sex
  should validate_presence_of :birth_country
  should validate_presence_of :paternal_grandfather_born_in
  should validate_presence_of :paternal_grandmother_born_in
  should validate_presence_of :maternal_grandfather_born_in
  should validate_presence_of :maternal_grandmother_born_in

  %w(citizen health_insurance health_or_medical_conditions prescriptions_in_last_year allergies).each do |boolean_attr|
    # PH: 2014-06-30 get a deprecation warning for this but can't replace with the following line because of "too many arguments" even though
    # I believe that allow_value has the (*values) signature...
    # WVW: update 2017-04-23: should allow_values works in newer versions of shoulda
    #should allow_values(true, false).for(boolean_attr)
    should_allow_values_for(boolean_attr, true, false)
    should_not allow_value(nil).for(boolean_attr).with_message("can't be blank")
  end
end
