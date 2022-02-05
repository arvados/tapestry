class AddBadEmailToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :bad_email, :boolean, :default => false
    add_column :user_versions, :bad_email, :boolean
  end

  def self.down
    remove_column :user_versions, :bad_email
    remove_column :users, :bad_email
  end
end
