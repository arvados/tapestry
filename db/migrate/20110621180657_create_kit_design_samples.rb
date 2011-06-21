class CreateKitDesignSamples < ActiveRecord::Migration
  def self.up
    create_table :kit_design_samples do |t|
      t.string :name
      t.text :description
      t.references :kit_design
      t.references :sample_type
      t.string :tissue
      t.string :device
      t.integer :sort_order
      t.string :target_amount
      t.string :unit
      t.boolean :frozen

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    KitDesignSample.create_versioned_table
  end

  def self.down
    KitDesignSample.drop_versioned_table
    drop_table :kit_design_samples
  end
end
