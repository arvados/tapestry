class AddWarehouseLocatorToUserFile < ActiveRecord::Migration
  def self.up
    add_column :user_files, :locator, :string
    add_column :user_file_versions, :locator, :string
  end

  def self.down
    remove_column :user_file_versions, :locator
    remove_column :user_files, :locator
  end
end
