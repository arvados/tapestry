class RenameRowTargetClassToRowTargetType < ActiveRecord::Migration
  def self.up
    rename_column :spreadsheets, :rowtarget_class, :rowtarget_type
    rename_column :spreadsheet_versions, :rowtarget_class, :rowtarget_type
    rename_column :google_spreadsheets, :rowtarget_class, :rowtarget_type
    rename_column :google_spreadsheet_versions, :rowtarget_class, :rowtarget_type
    rename_column :spreadsheet_rows, :row_target_class, :row_target_type
    rename_column :spreadsheet_row_versions, :row_target_class, :row_target_type
  end

  def self.down
    rename_column :spreadsheets, :rowtarget_type, :rowtarget_class
    rename_column :spreadsheet_versions, :rowtarget_type, :rowtarget_class
    rename_column :google_spreadsheets, :rowtarget_type, :rowtarget_class
    rename_column :google_spreadsheet_versions, :rowtarget_type, :rowtarget_class
    rename_column :spreadsheet_rows, :row_target_type, :row_target_class
    rename_column :spreadsheet_row_versions, :row_target_type, :row_target_class
  end
end
