class CreateDatasets < ActiveRecord::Migration
  def self.up
    create_table :datasets do |t|
      t.references :participant
      t.string :human_id
      t.string :sha1
      t.string :location
      t.string :build
      t.string :name
      t.text :researcher_notes
      t.timestamp :deleted_at
      t.timestamps
    end
    add_index :datasets, :participant_id
    add_index :datasets, :sha1
    Dataset.create_versioned_table
  end

  def self.down
    Dataset.drop_versioned_table
    remove_index :datasets, :sha1
    remove_index :datasets, :participant_id
    drop_table :datasets
  end
end
