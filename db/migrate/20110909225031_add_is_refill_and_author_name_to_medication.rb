class AddIsRefillAndAuthorNameToMedication < ActiveRecord::Migration
  def self.up
    add_column :medications, :is_refill, :boolean
    add_column :medications, :author_name, :string
    add_column :medication_versions, :is_refill, :boolean
    add_column :medication_versions, :author_name, :string
  end

  def self.down
    remove_column :medication_versions, :author_name
    remove_column :medication_versions, :is_refill
    remove_column :medications, :author_name
    remove_column :medications, :is_refill
  end
end
