class CreateSpreadsheets < ActiveRecord::Migration
  def self.up
    create_table :spreadsheets do |t|
      t.references :user

      t.string :name
      t.text :description

      t.string :rowtarget_class
      t.string :rowtarget_id_attribute
      t.string :rowtarget_data_attribute

      t.integer :row_id_column
      t.text :header_row

      t.integer :auto_update_interval
      t.boolean :is_auto_update_enabled
      t.timestamp :last_downloaded_at

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    Spreadsheet.create_versioned_table
  end

  def self.down
    Spreadsheet.drop_versioned_table
    drop_table :spreadsheets
  end
end
