class CreateKitLogs < ActiveRecord::Migration
  def self.up
    create_table :kit_logs do |t|
      t.references :kit
      t.references :actor
      t.text :comment

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    KitLog.create_versioned_table
  end

  def self.down
    KitLog.drop_versioned_table
    drop_table :kit_logs
  end
end
