class CreateShippingAddresses < ActiveRecord::Migration
  def self.up
    create_table :shipping_addresses do |t|
      t.references :user
      t.string :address_line_1
      t.string :address_line_2
      t.string :address_line_3
      t.string :city
      t.string :state
      t.string :zip

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    ShippingAddress.create_versioned_table
  end

  def self.down
    ShippingAddress.drop_versioned_table
    drop_table :shipping_addresses
  end
end
