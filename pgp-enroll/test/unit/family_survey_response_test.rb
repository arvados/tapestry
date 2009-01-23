require 'test_helper'

class FamilySurveyResponseTest < ActiveSupport::TestCase

  context 'a response' do
    setup do
      @family_survey_response = Factory(:family_survey_response)
    end

    should_belong_to :user

    should_require_attributes :birth_year, :relatives_interested_in_pgp, :monozygotic_twin, :child_situation

    should_allow_values_for     :birth_year, 1895, 1980, 1990, 2000, 2008, 2020
    should_not_allow_values_for :birth_year, -1, 1800, 1894, :message => 'must be answered'

    should_allow_values_for     :relatives_interested_in_pgp, '0', '1', '2', '3+' 
    should_not_allow_values_for :relatives_interested_in_pgp, '-1', 0, 1, 2, :message => 'must be answered'

    should_allow_values_for     :monozygotic_twin, 'no', 'willing', 'unwilling'
    should_not_allow_values_for :monozygotic_twin, 1, 0, 'yes', :message => 'must be answered'

    should_allow_values_for     :child_situation, 'some', 'none', 'never'
    should_not_allow_values_for :child_situation, 1, 'yes', :message => 'must be answered'

    should_allow_values_for     :youngest_child_age, nil, '', 0, 1, 2, 100
    should_not_allow_values_for :youngest_child_age, -1, :message => 'must be answered'

    context 'that indicated having children currently' do
      setup do
        @family_survey_response.child_situation = 'some'
      end

      context 'and did not specify youngest_child_age' do
        setup do
          @family_survey_response.youngest_child_age = nil
        end

        should 'not be valid' do
          assert ! @family_survey_response.valid?
        end

        should 'give an appropriate error message' do
          assert_equal 'must be filled out if you have children.',
                        @family_survey_response.errors.on(:youngest_child_age)
        end
      end
    end
  end

end
