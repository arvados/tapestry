class CreateSelections < ActiveRecord::Migration
  def self.up
    create_table :selections do |t|
      t.text :spec, :limit => 32.megabytes
      t.text :targets, :limit => 32.megabytes
      t.string :target_type

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    Selection.create_versioned_table
  end

  def self.down
    Selection.drop_versioned_table
    drop_table :selections
  end
end
