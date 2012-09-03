class AddLostAtToKit < ActiveRecord::Migration
  def self.up
    add_column :kits, :lost_at, :timestamp
    add_column :kit_versions, :lost_at, :timestamp
  end

  def self.down
    remove_column :kit_versions, :lost_at
    remove_column :kits, :lost_at
  end
end
