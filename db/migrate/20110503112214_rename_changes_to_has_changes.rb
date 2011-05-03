class RenameChangesToHasChanges < ActiveRecord::Migration
  def self.up
    rename_column :safety_questionnaires, :changes, :has_changes
  end

  def self.down
    rename_column :safety_questionnaires, :has_changes, :changes
  end
end
