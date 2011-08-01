class CreateSamples < ActiveRecord::Migration
  def self.up
    create_table :samples do |t|
      t.string :name
      t.integer :crc_id
      t.references :study
      t.references :kit
      t.integer :participant_id
      t.integer :original_kit_design_sample_id
      t.integer :kit_design_sample_id
      t.datetime :when_originated
      t.integer :owner_id
      t.datetime :last_mailed
      t.datetime :last_received
      t.string :participant_note
      t.string :researcher_note
      t.string :concentration
      t.string :amount
      t.string :unit
      t.string :material
      t.string :url_code

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :samples, :crc_id, :unique => true
    add_index :samples, :url_code, :unique => true
    Sample.create_versioned_table
  end

  def self.down
    Sample.drop_versioned_table
    remove_index :samples, :crc_id
    remove_index :samples, :url_code
    drop_table :samples
  end
end
