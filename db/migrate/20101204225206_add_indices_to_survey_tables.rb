class AddIndicesToSurveyTables < ActiveRecord::Migration
  def self.up
    add_index(:survey_questions, :survey_section_id)
    add_index(:survey_sections, :survey_id)
    add_index(:survey_answer_choices, :survey_question_id)
    add_index(:survey_answers, :survey_question_id)
    add_index(:survey_answers, :user_id)
  end

  def self.down
    remove_index(:survey_answers, :column => :user_id)
    remove_index(:survey_answers, :column => :survey_question_id)
    remove_index(:survey_answer_choices, :column => :survey_question_id)
    remove_index(:survey_sections, :column => :survey_id)
    remove_index(:survey_questions, :column => :survey_section_id)
  end
end
