class AddReportMetadataToDatasetAndUserFile < ActiveRecord::Migration
  def self.up
    add_column :datasets, :report_metadata, :text
    add_column :dataset_versions, :report_metadata, :text
    add_column :user_files, :report_metadata, :text
    add_column :user_file_versions, :report_metadata, :text
  end

  def self.down
    remove_column :user_file_versions, :report_metadata
    remove_column :user_files, :report_metadata
    remove_column :dataset_versions, :report_metadata
    remove_column :datasets, :report_metadata
  end
end
