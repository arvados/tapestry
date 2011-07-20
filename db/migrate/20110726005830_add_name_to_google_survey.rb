class AddNameToGoogleSurvey < ActiveRecord::Migration
  def self.up
    add_column :google_surveys, :name, :string
  end

  def self.down
    remove_column :google_surveys, :name
  end
end
