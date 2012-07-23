class AddInfoToUserLogs < ActiveRecord::Migration
  def self.up
    add_column :user_logs, :info, :text
    add_column :user_log_versions, :info, :text
  end

  def self.down
    remove_column :user_log_versions, :info
    remove_column :user_logs, :info
  end
end
