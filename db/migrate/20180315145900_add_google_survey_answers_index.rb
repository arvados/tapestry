class AddGoogleSurveyAnswersIndex < ActiveRecord::Migration
  def self.up
    add_index :google_survey_answers, [:nonce_id]
  end

  def self.down
    remove_index :google_survey_answers, [:nonce_id]
  end
end
