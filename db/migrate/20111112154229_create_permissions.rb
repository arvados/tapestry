class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.integer :granted_by_id
      t.integer :granted_to_id

      t.string :name
      t.string :description
      t.string :action
      t.string :subject_class
      t.integer :subject_id

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    Permission.create_versioned_table
  end

  def self.down
    Permission.drop_versioned_table
    drop_table :permissions
  end
end
