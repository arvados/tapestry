class AddProcessingStatusToDataset < ActiveRecord::Migration
  def self.up
    add_column :datasets, :processing_status, :text
    add_column :datasets, :processing_stopped, :boolean, :default => true, :null => false
    add_column :dataset_versions, :processing_status, :text
    add_column :dataset_versions, :processing_stopped, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :dataset_versions, :processing_stopped
    remove_column :dataset_versions, :processing_status
    remove_column :datasets, :processing_stopped
    remove_column :datasets, :processing_status
  end
end
