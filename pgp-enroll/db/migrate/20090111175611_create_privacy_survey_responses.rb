class CreatePrivacySurveyResponses < ActiveRecord::Migration
  def self.up
    create_table :privacy_survey_responses do |t|
      t.references :user
      t.string :worrisome_information_comfort_level
      t.string :information_disclosure_comfort_level
      t.string :past_genetic_test_participation

      t.timestamps
    end
  end

  def self.down
    drop_table :privacy_survey_responses
  end
end
