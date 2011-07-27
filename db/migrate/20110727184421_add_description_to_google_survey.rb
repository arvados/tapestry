class AddDescriptionToGoogleSurvey < ActiveRecord::Migration
  def self.up
    add_column :google_surveys, :description, :text
  end

  def self.down
    remove_column :google_surveys, :description
  end
end
