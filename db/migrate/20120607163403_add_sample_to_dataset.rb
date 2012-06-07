class AddSampleToDataset < ActiveRecord::Migration
  def self.up
    add_column :datasets, :sample_id, :integer
    add_column :dataset_versions, :sample_id, :integer
  end

  def self.down
    remove_column :dataset_versions, :sample_id
    remove_column :datasets, :sample_id
  end
end
