class CreateSampleTypes < ActiveRecord::Migration
  def self.up
    create_table :sample_types do |t|
      t.string :name
      t.references :tissue_type
      t.references :device_type
      t.text :description
      t.string :target_amount
      t.references :unit

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    SampleType.create_versioned_table
  end

  def self.down
    SampleType.drop_versioned_table
    drop_table :sample_types
  end
end
