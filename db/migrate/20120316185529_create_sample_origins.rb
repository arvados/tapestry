class CreateSampleOrigins < ActiveRecord::Migration
  def self.up
    create_table :sample_origins do |t|
      t.references :parent_sample
      t.references :child_sample
      t.string :derivation_method

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :sample_origins, :parent_sample_id
    add_index :sample_origins, :child_sample_id
    SampleOrigin.create_versioned_table
  end

  def self.down
    SampleOrigin.drop_versioned_table
    remove_index :sample_origins, :child_sample_id
    remove_index :sample_origins, :parent_sample_id
    drop_table :sample_origins
  end
end
