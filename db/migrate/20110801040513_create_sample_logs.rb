class CreateSampleLogs < ActiveRecord::Migration
  def self.up
    create_table :sample_logs do |t|
      t.references :sample
      t.references :actor
      t.text :comment

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    SampleLog.create_versioned_table
  end

  def self.down
    SampleLog.drop_versioned_table
    drop_table :sample_logs
  end
end
