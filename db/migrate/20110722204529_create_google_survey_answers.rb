class CreateGoogleSurveyAnswers < ActiveRecord::Migration
  def self.up
    create_table :google_survey_answers do |t|
      t.references :google_survey
      t.integer :column
      t.text :answer

      t.timestamps
    end
  end

  def self.down
    drop_table :google_survey_answers
  end
end
