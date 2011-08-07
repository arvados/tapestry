class AddMapToShippingAddress < ActiveRecord::Migration
  def self.up
    add_column :shipping_addresses, :latitude, :float
    add_column :shipping_addresses, :longitude, :float
    add_column :shipping_addresses, :gmaps, :boolean
  end

  def self.down
    remove_column :shipping_addresses, :latitude
    remove_column :shipping_addresses, :longitude
    remove_column :shipping_addresses, :gmaps
  end
end
