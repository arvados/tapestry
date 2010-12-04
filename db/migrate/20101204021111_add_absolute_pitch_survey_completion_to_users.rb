class AddAbsolutePitchSurveyCompletionToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :absolute_pitch_survey_completion, :datetime
  end

  def self.down
    remove_column :users, :absolute_pitch_survey_completion
  end
end
