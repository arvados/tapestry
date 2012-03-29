class AddRowTargetClassAndRowTargetIdToSpreadsheetRow < ActiveRecord::Migration
  def self.up
    add_column :spreadsheet_rows, :row_target_class, :string
    add_column :spreadsheet_rows, :row_target_id, :integer
    add_column :spreadsheet_row_versions, :row_target_class, :string
    add_column :spreadsheet_row_versions, :row_target_id, :integer
  end

  def self.down
    remove_column :spreadsheet_row_versions, :row_target_id
    remove_column :spreadsheet_row_versions, :row_target_class
    remove_column :spreadsheet_rows, :row_target_id
    remove_column :spreadsheet_rows, :row_target_class
  end
end
