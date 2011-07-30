class AddPhoneToShippingAddresses < ActiveRecord::Migration
  def self.up
    add_column :shipping_addresses, :phone, :string
    add_column :shipping_address_versions, :phone, :string
  end

  def self.down
    remove_column :shipping_address_versions, :phone
    remove_column :shipping_addresses, :phone
  end
end
