class AddPublicAndListedToGoogleSurvey < ActiveRecord::Migration
  def self.up
    add_column :google_surveys, :is_result_public, :boolean, :default => true
    add_column :google_surveys, :is_listed, :boolean, :default => true
  end

  def self.down
    remove_column :google_surveys, :is_listed
    remove_column :google_surveys, :is_result_public
  end
end
