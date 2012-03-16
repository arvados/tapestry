class AddDerivedFromPlateToPlate < ActiveRecord::Migration
  def self.up
    add_column :plates, :derived_from_plate_id, :integer
    add_column :plate_versions, :derived_from_plate_id, :integer
    add_index :plates, :derived_from_plate_id
  end

  def self.down
    remove_index :plates, :derived_from_plate_id
    remove_column :plate_versions, :derived_from_plate_id
    remove_column :plates, :derived_from_plate_id
  end
end
