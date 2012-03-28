class CreateSpreadsheetRows < ActiveRecord::Migration
  def self.up
    create_table :spreadsheet_rows do |t|
      t.references :spreadsheet
      t.integer :row_number
      t.text :row_data

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    SpreadsheetRow.create_versioned_table
  end

  def self.down
    SpreadsheetRow.drop_versioned_table
    drop_table :spreadsheet_rows
  end
end
