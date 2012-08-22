class AddUnguessableToSelection < ActiveRecord::Migration
  def self.up
    add_column :selections, :unguessable, :string
    add_column :selection_versions, :unguessable, :string
  end

  def self.down
    remove_column :selection_versions, :unguessable
    remove_column :selections, :unguessable
  end
end
