class AddSuspendColumnsToUserVersions < ActiveRecord::Migration
  def self.up
    add_column :user_versions, :deactivated_at, :datetime
    add_column :user_versions, :suspended_at, :datetime
    add_column :user_versions, :can_reactivate_self, :boolean
  end

  def self.down
    remove_column :user_versions, :can_reactivate_self
    remove_column :user_versions, :suspended_at
    remove_column :user_versions, :deactivated_at
  end
end
