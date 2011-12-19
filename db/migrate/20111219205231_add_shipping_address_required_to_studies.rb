class AddShippingAddressRequiredToStudies < ActiveRecord::Migration
  def self.up
    add_column :studies, :shipping_address_required, :boolean, :default => true
    add_column :studies, :phone_number_required, :boolean, :default => false
    add_column :study_versions, :shipping_address_required, :boolean
    add_column :study_versions, :phone_number_required, :boolean
  end

  def self.down
    remove_column :study_versions, :shipping_address_required
    remove_column :study_versions, :phone_number_required
    remove_column :studies, :shipping_address_required
    remove_column :studies, :phone_number_required
  end
end
