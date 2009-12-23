require 'test_helper'

class FamilySurveyResponseTest < ActiveSupport::TestCase

  def self.should_not_be_eligible
    should 'not be eligible' do
      assert ! @family_survey_response.eligible?
    end
  end

  def self.should_be_eligible
    should 'be eligible' do
      assert @family_survey_response.eligible?
    end
  end

  context 'an ineligible response' do
    setup { @family_survey_response = Factory(:ineligible_family_survey_response) }
    should_not_be_eligible
  end

  context 'a response' do
    setup do
      @family_survey_response = Factory(:family_survey_response)
    end

    should_be_eligible

    should_belong_to :user

    should_not_allow_mass_assignment_of :user_id

    should_validate_presence_of :birth_year, :relatives_interested_in_pgp, :monozygotic_twin, :child_situation

    should_allow_values_for     :birth_year, 1895, 1980, 1990, 2000, 2008, 2020
    should_not_allow_values_for :birth_year, -1, 1800, 1894, :message => 'must be answered'

    should_allow_values_for     :relatives_interested_in_pgp, '0', '1', '2', '3+' 
    should_not_allow_values_for :relatives_interested_in_pgp, '-1', 0, 1, 2, :message => 'must be answered'

    #TODO why did should_allow_values_for not work properly (didn't fail for new value)
    %w(no willing unwilling unknown).each do |value|
      should "allow #{value} for :monozygotic_twin" do
        @family_survey_response.monozygotic_twin = value
        assert @family_survey_response.valid?
      end
    end

    should_not_allow_values_for :monozygotic_twin, 1, 0, 'yes', :message => 'must be answered'

    %w(some none never unknown).each do |value|
      should "allow #{value} for :child_situation" do
        @family_survey_response.youngest_child_birth_year = 2000
        @family_survey_response.child_situation = value
        assert @family_survey_response.valid?, @family_survey_response.errors.inspect
      end
    end

    should_not_allow_values_for :child_situation, 1, 'yes', :message => 'must be answered'

    should_allow_values_for     :youngest_child_birth_year, nil, '', 1985, 2000, 2008, 2020
    should_not_allow_values_for :youngest_child_birth_year, -1, :message => 'must be filled out if you have children'

    context 'that indicated having children currently and did not specify youngest_child_age' do
      setup do
        @family_survey_response.child_situation = 'some'
        @family_survey_response.youngest_child_birth_year = nil
      end

      should 'not be valid' do
        assert ! @family_survey_response.valid?
      end

      should 'give an appropriate error message' do
        @family_survey_response.valid?
        assert_equal 'must be filled out if you have children.',
                      @family_survey_response.errors.on(:youngest_child_birth_year)
      end
    end

    should 'respond to #eligible?' do
      assert @family_survey_response.respond_to?(:eligible?)
    end

    context 'where the user is under 21' do
      setup { @family_survey_response.birth_year = Time.now.year - 19 }
      should_not_be_eligible
    end

    context 'who has a monozygotic_twin who is not willing to participate' do
      setup { @family_survey_response.monozygotic_twin = 'unwilling' }
      should_not_be_eligible
    end

    context 'who is over 21 and does not have a non-willing monozygotic twin' do
      should_be_eligible
    end
  end

  should "have a waitlist_message" do
    assert Factory(:family_survey_response).respond_to?(:waitlist_message)
    assert ! Factory(:family_survey_response).waitlist_message.empty?
  end

end
