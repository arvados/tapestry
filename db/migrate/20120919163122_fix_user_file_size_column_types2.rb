class FixUserFileSizeColumnTypes2 < ActiveRecord::Migration
  def self.up
    change_column :user_files, :longupload_bytes_received, :integer, :limit => 8
    change_column :user_file_versions, :longupload_bytes_received, :integer, :limit => 8
  end

  def self.down
    change_column :user_file_versions, :longupload_bytes_received, :integer
    change_column :user_files, :longupload_bytes_received, :integer
  end
end
