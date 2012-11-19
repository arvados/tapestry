class RemoveBooleanFromUserVersions < ActiveRecord::Migration
  def self.up
    remove_column :user_versions, :boolean
  end

  def self.down
    add_column :user_versions, :boolean, :datetime
  end
end
