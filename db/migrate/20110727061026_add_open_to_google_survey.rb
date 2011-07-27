class AddOpenToGoogleSurvey < ActiveRecord::Migration
  def self.up
    add_column :google_surveys, :open, :boolean
  end

  def self.down
    remove_column :google_surveys, :open
  end
end
