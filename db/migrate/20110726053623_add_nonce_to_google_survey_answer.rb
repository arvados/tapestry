class AddNonceToGoogleSurveyAnswer < ActiveRecord::Migration
  def self.up
    add_column :google_survey_answers, :nonce_id, :integer
  end

  def self.down
    remove_column :google_survey_answers, :nonce_id
  end
end
