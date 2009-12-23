require 'test_helper'

class BaselineTraitsSurveyTest < ActiveSupport::TestCase
  should_belong_to :user
  should_validate_presence_of :sex,
                              :birth_country,
                              :paternal_grandfather_born_in,
                              :paternal_grandmother_born_in,
                              :maternal_grandfather_born_in,
                              :maternal_grandmother_born_in

  %w(us_citizen health_insurance health_or_medical_conditions prescriptions_in_last_year allergies).each do |boolean_attr|
    should_allow_values_for boolean_attr, true, false
    should_not_allow_values_for boolean_attr, nil, :message => "can't be blank"
  end
end
