require 'test_helper'

class FamilySurveyResponseTest < ActiveSupport::TestCase

  context 'a response' do
    setup do
      @family_survey_response = Factory(:family_survey_response)
    end

    should_belong_to :user

    should_require_attributes :birth_year, :relatives_interested_in_pgp, :monozygotic_twin, :child_situation

    should_allow_values_for     :birth_year, 1895, 1980, 1990, 2000, 2008, 2020
    should_not_allow_values_for :birth_year, -1, 1800, 1894

    should_allow_values_for     :relatives_interested_in_pgp, '0', '1', '2', '3+' 
    should_not_allow_values_for :relatives_interested_in_pgp, '-1', 0, 1, 2

    should_allow_values_for     :monozygotic_twin, 'no', 'yes-willing', 'yes-unwilling'
    should_not_allow_values_for :monozygotic_twin, 1, 0, 'yes'

    should_allow_values_for     :child_situation, 'some', 'none', 'never'
    should_not_allow_values_for :child_situation, 1, 'yes'

    should_allow_values_for     :youngest_child_age, nil, '', 0, 1, 2, 100
    should_not_allow_values_for :youngest_child_age, -1
  end

end
