class AddFormUrlToGoogleSurvey < ActiveRecord::Migration
  def self.up
    add_column :google_surveys, :form_url, :string
  end

  def self.down
    remove_column :google_surveys, :form_url
  end
end
