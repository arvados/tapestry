class CreateSpreadsheetImporters < ActiveRecord::Migration
  def self.up
    create_table :spreadsheet_importers do |t|
      t.references :spreadsheet
      t.string :type

      # For SpreadsheetImporterGoogle
      t.references :oauth_service
      t.string :gdocs_url

      # For SpreadsheetImporterTraitwise
      t.references :traitwise_survey

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    SpreadsheetImporter.create_versioned_table
  end

  def self.down
    SpreadsheetImporter.drop_versioned_table
    drop_table :spreadsheet_importers
  end
end
