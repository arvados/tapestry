class AddRealNamePublicToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :real_name_public, :boolean, :default => false
    add_column :user_versions, :real_name_public, :boolean
  end

  def self.down
    remove_column :user_versions, :real_name_public
    remove_column :users, :real_name_public
  end
end
