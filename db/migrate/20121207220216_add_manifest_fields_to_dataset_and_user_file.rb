class AddManifestFieldsToDatasetAndUserFile < ActiveRecord::Migration
  def self.up
    add_column :datasets, :path_in_manifest, :string
    add_column :datasets, :index_in_manifest, :integer
    add_column :user_files, :path_in_manifest, :string
    add_column :user_files, :index_in_manifest, :integer
    add_column :dataset_versions, :path_in_manifest, :string
    add_column :dataset_versions, :index_in_manifest, :integer
    add_column :user_file_versions, :path_in_manifest, :string
    add_column :user_file_versions, :index_in_manifest, :integer
  end

  def self.down
    remove_column :datasets, :path_in_manifest
    remove_column :datasets, :index_in_manifest
    remove_column :user_files, :path_in_manifest
    remove_column :user_files, :index_in_manifest
    remove_column :dataset_versions, :path_in_manifest
    remove_column :dataset_versions, :index_in_manifest
    remove_column :user_file_versions, :path_in_manifest
    remove_column :user_file_versions, :index_in_manifest
  end
end
