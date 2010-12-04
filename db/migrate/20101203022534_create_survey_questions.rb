class CreateSurveyQuestions < ActiveRecord::Migration
  def self.up
    create_table :survey_questions do |t|
      t.integer :survey_section_id
      t.string :text
      t.string :note
      t.string :question_type
      t.timestamps
    end
  end

  def self.down
    drop_table :survey_questions
  end
end
