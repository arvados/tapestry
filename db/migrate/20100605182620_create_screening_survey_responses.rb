class CreateScreeningSurveyResponses < ActiveRecord::Migration
  def self.up
    create_table :screening_survey_responses do |t|
      t.references :user
      t.boolean :us_citizen
      t.boolean :age_21
      t.string :monozygotic_twin
      t.string :worrisome_information_comfort_level
      t.string :information_disclosure_comfort_level
      t.string :past_genetic_test_participation

      t.timestamps
    end
    User.find(:all).each do |u|
      if (u.residency_survey_response or u.family_survey_response or u.privacy_survey_response) then
        u.screening_survey_response = ScreeningSurveyResponse.new()
        s = u.screening_survey_response
        if (u.baseline_traits_survey) then
          s.us_citizen = u.baseline_traits_survey.us_citizen
        end
        if (u.family_survey_response) then
          s.age_21 = u.family_survey_response.birth_year < (Time.now.year - 21)
          s.monozygotic_twin = u.family_survey_response.monozygotic_twin
        end
        if (u.privacy_survey_response) then
          s.worrisome_information_comfort_level = u.privacy_survey_response.worrisome_information_comfort_level
          s.information_disclosure_comfort_level = u.privacy_survey_response.information_disclosure_comfort_level
          s.past_genetic_test_participation = u.privacy_survey_response.past_genetic_test_participation
        end
        s.save!
      end
    end
  end

  def self.down
    drop_table :screening_survey_responses
  end
end
