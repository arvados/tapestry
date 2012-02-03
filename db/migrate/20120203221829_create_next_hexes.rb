class CreateNextHexes < ActiveRecord::Migration
  def self.up
    create_table :next_hexes do |t|
      t.string :hex

      t.timestamps
    end
  end

  def self.down
    drop_table :next_hexes
  end
end
