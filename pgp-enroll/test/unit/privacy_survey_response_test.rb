require 'test_helper'

class PrivacySurveyResponseTest < ActiveSupport::TestCase

  def self.should_not_be_eligible
    should 'not be eligible' do
      assert ! @privacy_survey_response.eligible?
    end
  end

  def self.should_be_eligible
    should 'be eligible' do
      assert @privacy_survey_response.eligible?
    end
  end

  context 'a privacy survey response' do
    setup do
      @privacy_survey_response = Factory(:privacy_survey_response)
    end

    should_belong_to :user

    should_allow_values_for     :worrisome_information_comfort_level, 'understand', 'uncomfortable', 'unsure', 'always', 'depends'
    should_not_allow_values_for :worrisome_information_comfort_level, nil, '', 'asdf', :message => 'must be answered'

    should_allow_values_for     :information_disclosure_comfort_level, 'understand', 'uncomfortable', 'unsure', 'comfortable', 'depends'
    should_not_allow_values_for :information_disclosure_comfort_level, nil, '', 'asdf', :message => 'must be answered'

    should_allow_values_for     :past_genetic_test_participation, 'yes', 'no', 'confidential', 'unsure', 'public'
    should_not_allow_values_for :past_genetic_test_participation, nil, '', 'asdf', :message => 'must be answered'

    should 'respond_to eligible?' do
      assert @privacy_survey_response.respond_to?(:eligible?)
    end

    context 'where the privacy_survey_response is otherwise eligible' do
      setup do
        @privacy_survey_response.past_genetic_test_participation = 'public'
        @privacy_survey_response.information_disclosure_comfort_level = 'comfortable'
        @privacy_survey_response.worrisome_information_comfort_level = 'always'

        assert @privacy_survey_response.eligible?
      end

      %w(public).each do |eligible_answer|
        context "where past_genetic_test_participation is #{eligible_answer}" do
          setup { @privacy_survey_response.past_genetic_test_participation = eligible_answer }
          should_be_eligible
        end
      end

      %w(yes no confidential unsure).each do |eligible_answer|
        context "where past_genetic_test_participation is #{eligible_answer}" do
          setup { @privacy_survey_response.past_genetic_test_participation = eligible_answer }
          should_not_be_eligible
        end
      end

      %w(understand comfortable).each do |eligible_answer|
        context "where information_disclosure_comfort_level is #{eligible_answer}" do
          setup { @privacy_survey_response.information_disclosure_comfort_level = eligible_answer }
          should_be_eligible
        end
      end

      %w(uncomfortable unsure depends).each do |eligible_answer|
        context "where information_disclosure_comfort_level is #{eligible_answer}" do
          setup { @privacy_survey_response.information_disclosure_comfort_level = eligible_answer }
          should_not_be_eligible
        end
      end

      %w(understand always).each do |eligible_answer|
        context "where worrisome_information_comfort_level is #{eligible_answer}" do
          setup { @privacy_survey_response.worrisome_information_comfort_level = eligible_answer }
          should_be_eligible
        end
      end

      %w(uncomfortable unsure depends).each do |eligible_answer|
        context "where worrisome_information_comfort_level is #{eligible_answer}" do
          setup { @privacy_survey_response.worrisome_information_comfort_level = eligible_answer }
          should_not_be_eligible
        end
      end
    end

  end

end
