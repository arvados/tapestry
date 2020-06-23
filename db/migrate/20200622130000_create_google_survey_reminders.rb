class CreateGoogleSurveyReminders < ActiveRecord::Migration
  def self.up
    create_table :google_survey_reminders do |t|
      t.integer :user_id
      t.integer :google_survey_id
      t.integer :frequency, :default => 0
      t.datetime :last_sent

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at
      t.timestamps
    end
    GoogleSurveyReminder.reset_column_information
    GoogleSurveyReminder.create_versioned_table
  end

  def self.down
    GoogleSurveyReminder.drop_versioned_table
    drop_table :google_survey_reminders
  end
end
