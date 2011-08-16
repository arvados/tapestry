class CreatePlateSamples < ActiveRecord::Migration
  def self.up
    create_table :plate_samples do |t|
      t.references :plate
      t.references :plate_layout_position
      t.references :sample
      t.boolean :is_unusable
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :plate_samples, [:plate_id, :plate_layout_position_id], :unique => true
    PlateSample.create_versioned_table
  end

  def self.down
    PlateSample.drop_versioned_table
    remove_index :plate_samples, [:plate_id, :plate_layout_position_id]
    drop_table :plate_samples
  end
end
