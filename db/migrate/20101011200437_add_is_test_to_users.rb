class AddIsTestToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_test, :boolean, :default => false
  end

  def self.down
    remove_column :users, :is_test
  end
end
