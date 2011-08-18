class CreatePlateLayouts < ActiveRecord::Migration
  def self.up
    create_table :plate_layouts do |t|
      t.string :name
      t.timestamp :deleted_at

      t.timestamps
    end
    PlateLayout.create_versioned_table
    PlateLayout.create :name => "96-well plate"
  end

  def self.down
    PlateLayout.drop_versioned_table
    drop_table :plate_layouts
  end
end
