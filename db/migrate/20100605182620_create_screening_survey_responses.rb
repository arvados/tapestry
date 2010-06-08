class CreateScreeningSurveyResponses < ActiveRecord::Migration
  def self.up
    create_table :screening_survey_responses do |t|
      t.references :user
      t.boolean :us_resident
      t.boolean :age_21
      t.string :monozygotic_twin
      t.string :worrisome_information_comfort_level
      t.string :information_disclosure_comfort_level
      t.string :past_genetic_test_participation

      t.timestamps
    end
  end

  def self.down
    drop_table :screening_survey_responses
  end
end
