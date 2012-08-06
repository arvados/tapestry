class AddStatusUrlAndProcessingStatusToUserFile < ActiveRecord::Migration
  def self.up
    add_column :user_files, :status_url, :string
    add_column :user_files, :processing_status, :text
    add_column :user_files, :processing_stopped, :boolean, :default => false, :null => false
    add_column :user_file_versions, :status_url, :string
    add_column :user_file_versions, :processing_status, :text
    add_column :user_file_versions, :processing_stopped, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :user_file_versions, :processing_stopped
    remove_column :user_file_versions, :processing_status
    remove_column :user_file_versions, :status_url
    remove_column :user_files, :processing_stopped
    remove_column :user_files, :processing_status
    remove_column :user_files, :status_url
  end
end
