class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.references :user
      t.string :name
      t.string :rtype
      t.datetime :requested
      t.datetime :created
      t.string :path
      t.string :status

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :reports, :created
    Report.create_versioned_table
  end

  def self.down
    Report.drop_versioned_table

    drop_table :reports
  end
end
