class CreateUnits < ActiveRecord::Migration
  def self.up
    create_table :units do |t|
      t.string :name

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    Unit.create_versioned_table
  end

  def self.down
    Unit.drop_versioned_table
    drop_table :units
  end
end
