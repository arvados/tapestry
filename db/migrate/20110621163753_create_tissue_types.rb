class CreateTissueTypes < ActiveRecord::Migration
  def self.up
    create_table :tissue_types do |t|
      t.string :name

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    TissueType.create_versioned_table
  end

  def self.down
    TissueType.drop_versioned_table
    drop_table :tissue_types
  end
end
