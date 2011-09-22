class AddControllingUserToKitLog < ActiveRecord::Migration
  def self.up
    add_column :kit_logs, :controlling_user_id, :integer
    add_column :kit_log_versions, :controlling_user_id, :integer
  end

  def self.down
    remove_column :kit_log_versions, :controlling_user_id
    remove_column :kit_logs, :controlling_user_id
  end
end
