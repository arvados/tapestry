class AddDeceasedToUserVersions < ActiveRecord::Migration
  def self.up
    add_column :user_versions, :deceased, :boolean, :default => nil
  end

  def self.down
    remove_column :user_versions, :deceased
  end
end
