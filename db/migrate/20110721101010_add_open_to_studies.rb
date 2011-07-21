class AddOpenToStudies < ActiveRecord::Migration
  def self.up
    add_column :studies, :open, :boolean, :default => false
    add_column :study_versions, :open, :boolean, :default => false
  end

  def self.down
    remove_column :study_versions, :open
    remove_column :studies, :open
  end
end
