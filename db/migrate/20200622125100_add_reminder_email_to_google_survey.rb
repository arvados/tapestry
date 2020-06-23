class AddReminderEmailToGoogleSurvey < ActiveRecord::Migration
  def self.up
    add_column :google_surveys, :reminder_email_subject, :string
    add_column :google_survey_versions, :reminder_email_subject, :string
    add_column :google_surveys, :reminder_email_body, :text
    add_column :google_survey_versions, :reminder_email_body, :text
    add_column :google_surveys, :reminder_email_frequency, :string
    add_column :google_survey_versions, :reminder_email_frequency, :string
  end

  def self.down
    remove_column :google_surveys, :reminder_email_subject
    remove_column :google_survey_versions, :reminder_email_subject
    remove_column :google_surveys, :reminder_email_body
    remove_column :google_survey_versions, :reminder_email_body
    remove_column :google_surveys, :reminder_email_frequency
    remove_column :google_survey_versions, :reminder_email_frequency
  end
end
