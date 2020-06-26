class AddBypassFieldTitleToGoogleSurvey < ActiveRecord::Migration
  def self.up
    add_column :google_surveys, :bypass_field_title, :string
    add_column :google_survey_versions, :bypass_field_title, :string
  end

  def self.down
    remove_column :google_surveys, :bypass_field_title
    remove_column :google_survey_versions, :bypass_field_title
  end
end
