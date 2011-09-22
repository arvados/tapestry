class AddControllingUserToSampleLog < ActiveRecord::Migration
  def self.up
    add_column :sample_logs, :controlling_user_id, :integer
    add_column :sample_log_versions, :controlling_user_id, :integer
  end

  def self.down
    remove_column :sample_log_versions, :controlling_user_id
    remove_column :sample_logs, :controlling_user_id
  end
end
