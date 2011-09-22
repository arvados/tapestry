class AddControllingUserToUserLog < ActiveRecord::Migration
  def self.up
    add_column :user_logs, :controlling_user_id, :integer
    add_column :user_log_versions, :controlling_user_id, :integer
  end

  def self.down
    remove_column :user_log_versions, :controlling_user_id
    remove_column :user_logs, :controlling_user_id
  end
end
