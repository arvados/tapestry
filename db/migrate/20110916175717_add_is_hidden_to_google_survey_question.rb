class AddIsHiddenToGoogleSurveyQuestion < ActiveRecord::Migration
  def self.up
    add_column :google_survey_questions, :is_hidden, :boolean
  end

  def self.down
    remove_column :google_survey_questions, :is_hidden
  end
end
