class AddDeactivatedAtAndSuspendedAtToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :deactivated_at, :timestamp
    add_column :users, :suspended_at, :timestamp
  end

  def self.down
    remove_column :users, :suspended_at
    remove_column :users, :deactivated_at
  end
end
