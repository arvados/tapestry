class CreateGoogleSurveyBypass < ActiveRecord::Migration
  def self.up
    create_table :google_survey_bypasses do |t|
      t.integer :user_id
      t.integer :google_survey_id
      t.string  :token
      t.datetime :used, :default => nil

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at
      t.timestamps
    end
    GoogleSurveyBypass.reset_column_information
    GoogleSurveyBypass.create_versioned_table
  end

  def self.down
    GoogleSurveyBypass.drop_versioned_table
    drop_table :google_survey_bypasses
  end
end
