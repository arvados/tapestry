class AddHeaderRowToGoogleSpreadsheet < ActiveRecord::Migration
  def self.up
    add_column :google_spreadsheets, :header_row, :text
    add_column :google_spreadsheet_versions, :header_row, :text
  end

  def self.down
    remove_column :google_spreadsheet_versions, :header_row
    remove_column :google_spreadsheets, :header_row
  end
end
