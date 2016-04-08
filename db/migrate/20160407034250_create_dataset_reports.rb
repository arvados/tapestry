class CreateDatasetReports < ActiveRecord::Migration
  def self.up
    create_table :dataset_reports do |t|
      t.references :dataset
      t.references :user_file
      t.string :title
      t.string :display_url
      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    DatasetReport.reset_column_information
    DatasetReport.create_versioned_table
  end

  def self.down
    DatasetReport.drop_versioned_table
    drop_table :dataset_reports
  end
end
