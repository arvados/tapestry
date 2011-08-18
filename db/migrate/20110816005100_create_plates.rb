class CreatePlates < ActiveRecord::Migration
  def self.up
    create_table :plates do |t|
      t.integer :crc_id
      t.string :url_code
      t.references :creator
      t.references :plate_layout
      t.text :description
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :plates, :crc_id, :unique => true
    add_index :plates, :url_code, :unique => true
    Plate.create_versioned_table
  end

  def self.down
    Plate.drop_versioned_table
    remove_index :plates, :crc_id
    remove_index :plates, :url_code
    drop_table :plates
  end
end
