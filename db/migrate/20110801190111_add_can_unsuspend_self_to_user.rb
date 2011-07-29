class AddCanUnsuspendSelfToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :can_unsuspend_self, :boolean
  end

  def self.down
    remove_column :users, :can_unsuspend_self
  end
end
