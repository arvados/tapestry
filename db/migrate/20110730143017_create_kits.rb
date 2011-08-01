class CreateKits < ActiveRecord::Migration
  def self.up
    create_table :kits do |t|
      t.string :name
      t.integer :crc_id
      t.references :study
      t.references :kit_design
      t.integer :participant_id
      t.integer :owner_id
      t.integer :originator_id
      t.integer :shipper_id
      t.timestamp :last_mailed
      t.timestamp :last_received
      t.string :url_code

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :kits, :name, :unique => true
    add_index :kits, :crc_id, :unique => true
    add_index :kits, :url_code, :unique => true
    Kit.create_versioned_table

  end

  def self.down
    Kit.drop_versioned_table

    drop_table :kits
  end
end
