class AddReportUrlToUserFile < ActiveRecord::Migration
  def self.up
    add_column :user_files, :report_url, :string
    add_column :user_file_versions, :report_url, :string
  end

  def self.down
    remove_column :user_file_versions, :report_url
    remove_column :user_files, :report_url
  end
end
