class CreateSurveyAnswerChoices < ActiveRecord::Migration
  def self.up
    create_table :survey_answer_choices do |t|
      t.integer :survey_question_id
      t.string :text
      t.string :value
      t.integer :order
      t.timestamps
    end
  end

  def self.down
    drop_table :survey_answer_choices
  end
end
