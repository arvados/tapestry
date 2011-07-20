class CreateGoogleSurveys < ActiveRecord::Migration
  def self.up
    create_table :google_surveys do |t|
      t.references :user
      t.references :oauth_service
      t.string :spreadsheet_key
      t.string :userid_hash_secret
      t.integer :userid_populate_entry
      t.integer :userid_response_column
      t.timestamp :last_downloaded_at

      t.timestamps
    end
  end

  def self.down
    drop_table :google_surveys
  end
end
