class CreateGoogleSpreadsheets < ActiveRecord::Migration
  def self.up
    create_table :google_spreadsheets do |t|
      t.references :user
      t.references :oauth_service
      t.string :name
      t.text :description
      t.string :gdocs_url
      t.string :rowtarget_class
      t.string :rowtarget_id_attribute
      t.string :rowtarget_data_attribute
      t.integer :row_id_column

      t.integer :auto_update_interval
      t.boolean :is_auto_update_enabled
      t.timestamp :last_downloaded_at

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    GoogleSpreadsheet.create_versioned_table
  end

  def self.down
    GoogleSpreadsheet.drop_versioned_table
    drop_table :google_spreadsheets
  end
end
