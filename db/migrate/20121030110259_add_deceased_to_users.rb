class AddDeceasedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :deceased, :boolean, :default => nil
    add_column :user_versions, :boolean, :datetime
  end

  def self.down
    remove_column :user_versions, :deceased
    remove_column :users, :deceased
  end
end
