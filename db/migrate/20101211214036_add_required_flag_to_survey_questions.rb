class AddRequiredFlagToSurveyQuestions < ActiveRecord::Migration
  def self.up
    add_column :survey_questions, :is_required, :boolean
  end

  def self.down
    remove_column :survey_questions, :is_required
  end
end
