class FixUserFileSizeColumnTypes < ActiveRecord::Migration
  def self.up
    change_column :user_files, :longupload_size, :integer, :limit => 8
    change_column :user_files, :dataset_file_size, :integer, :limit => 8
    change_column :user_files, :warehouse_blocks, :text, :limit => 64.megabytes
    change_column :user_file_versions, :longupload_size, :integer, :limit => 8
    change_column :user_file_versions, :dataset_file_size, :integer, :limit => 8
    change_column :user_file_versions, :warehouse_blocks, :text, :limit => 64.megabytes
  end

  def self.down
    change_column :user_file_versions, :longupload_size, :integer
    change_column :user_file_versions, :dataset_file_size, :integer
    change_column :user_file_versions, :warehouse_blocks, :text
    change_column :user_files, :longupload_size, :integer
    change_column :user_files, :dataset_file_size, :integer
    change_column :user_files, :warehouse_blocks, :text
  end
end
