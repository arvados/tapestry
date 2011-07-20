class CreateGoogleSurveyQuestions < ActiveRecord::Migration
  def self.up
    create_table :google_survey_questions do |t|
      t.references :google_survey
      t.integer :column
      t.text :question

      t.timestamps
    end
  end

  def self.down
    drop_table :google_survey_questions
  end
end
