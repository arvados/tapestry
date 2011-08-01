class CreateUnusedKitNames < ActiveRecord::Migration
  def self.up
    create_table :unused_kit_names do |t|
      t.string :name

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :unused_kit_names, :name, :unique => true
    UnusedKitName.create_versioned_table
  end

  def self.down
    UnusedKitName.drop_versioned_table
    drop_table :unused_kit_names
  end
end
