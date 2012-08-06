class AddStatusUrlAndDownloadUrlToDataset < ActiveRecord::Migration
  def self.up
    add_column :datasets, :status_url, :string, :default => nil
    add_column :datasets, :download_url, :string, :default => nil
    add_column :dataset_versions, :status_url, :string, :default => nil
    add_column :dataset_versions, :download_url, :string, :default => nil
  end

  def self.down
    remove_column :dataset_versions, :download_url
    remove_column :dataset_versions, :status_url
    remove_column :datasets, :download_url
    remove_column :datasets, :status_url
  end
end
