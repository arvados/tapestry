class CreateDeviceTypes < ActiveRecord::Migration
  def self.up
    create_table :device_types do |t|
      t.string :name
      t.text :description

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    DeviceType.create_versioned_table
  end

  def self.down
    DeviceType.drop_versioned_table
    drop_table :device_types
  end
end
