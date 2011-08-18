class CreatePlateLayoutPositions < ActiveRecord::Migration
  def self.up
    create_table :plate_layout_positions do |t|
      t.references :plate_layout
      t.integer :xpos
      t.integer :ypos
      t.string :name
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :plate_layout_positions, [:plate_layout_id, :xpos, :ypos], :unique => true, :name => "index_plate_layout_positions_on_plate_layout_id_xpos_ypos"
    add_index :plate_layout_positions, [:plate_layout_id, :name], :unique => true
    PlateLayoutPosition.create_versioned_table
    (1..8).each {|y|
      (1..12).each {|x|
        PlateLayoutPosition.create (:plate_layout => PlateLayout.find_by_name("96-well plate"),
                                    :name => "%s%02d" % [(y+9).to_s(32).upcase, x],
                                    :xpos => x,
                                    :ypos => y)
      }
    }
  end

  def self.down
    PlateLayoutPosition.drop_versioned_table
    remove_index :plate_layout_positions, [:plate_layout_id, :name]
    remove_index :plate_layout_positions, :name => :index_plate_layout_positions_on_plate_layout_id_xpos_ypos
    drop_table :plate_layout_positions
  end
end
