class CreateGoogleSpreadsheetRows < ActiveRecord::Migration
  def self.up
    create_table :google_spreadsheet_rows do |t|
      t.references :google_spreadsheet
      t.integer :row_number
      t.text :row_data

      t.timestamps
    end
    add_index(:google_spreadsheet_rows,
              [:google_spreadsheet_id, :row_number],
              {
                :unique => true,
                :name => 'index_google_spreadsheet_rows_on_spreadsheet_and_row_number'
              })
  end

  def self.down
    remove_index(:google_spreadsheet_rows,
                 :name => 'index_google_spreadsheet_rows_on_spreadsheet_and_row_number')
    drop_table :google_spreadsheet_rows
  end
end
