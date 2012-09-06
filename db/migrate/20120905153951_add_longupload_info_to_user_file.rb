class AddLonguploadInfoToUserFile < ActiveRecord::Migration
  def self.up
    [:user_files, :user_file_versions].each do |t|
      add_column t, :longupload_fingerprint, :string
      add_column t, :longupload_file_name, :string
      add_column t, :longupload_size, :integer
      add_column t, :longupload_bytes_received, :integer
      add_column t, :warehouse_blocks, :text
    end
  end

  def self.down
    [:user_files, :user_file_versions].each do |t|
      remove_column t, :warehouse_blocks
      remove_column t, :longupload_bytes_received
      remove_column t, :longupload_size
      remove_column t, :longupload_file_name
      remove_column t, :longupload_fingerprint
    end
  end
end
