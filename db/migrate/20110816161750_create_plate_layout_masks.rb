class CreatePlateLayoutMasks < ActiveRecord::Migration
  def self.up
    create_table :plate_layout_masks do |t|
      t.string :name
      t.integer :xmodulus
      t.integer :ymodulus
      t.integer :xtarget
      t.integer :ytarget
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :plate_layout_masks, [:xmodulus, :ymodulus, :xtarget, :ytarget], :unique => true, :name => "plate_layout_masks_on_modulus_and_target"
    PlateLayout.create_versioned_table
    PlateLayoutMask.create(:name => "No mask",
                           :xmodulus => 1, :ymodulus => 1,
                           :xtarget => 0, :ytarget => 0)
    PlateLayoutMask.create(:name => "Top left",
                           :xmodulus => 2, :ymodulus => 2,
                           :xtarget => 0, :ytarget => 0)
    PlateLayoutMask.create(:name => "Top right",
                           :xmodulus => 2, :ymodulus => 2,
                           :xtarget => 1, :ytarget => 0)
    PlateLayoutMask.create(:name => "Bottom left",
                           :xmodulus => 2, :ymodulus => 2,
                           :xtarget => 0, :ytarget => 1)
    PlateLayoutMask.create(:name => "Bottom right",
                           :xmodulus => 2, :ymodulus => 2,
                           :xtarget => 1, :ytarget => 1)
  end

  def self.down
    PlateLayout.drop_versioned_table
    remove_index :plate_layout_masks, :name => :plate_layout_masks_on_modulus_and_target
    drop_table :plate_layout_masks
  end
end
