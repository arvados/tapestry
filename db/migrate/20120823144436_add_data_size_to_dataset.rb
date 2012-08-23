class AddDataSizeToDataset < ActiveRecord::Migration
  def self.up
    add_column :datasets, :data_size, :integer
    add_column :dataset_versions, :data_size, :integer
  end

  def self.down
    remove_column :dataset_versions, :data_size
    remove_column :datasets, :data_size
  end
end
