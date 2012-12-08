class FixDatasetDataSizeType < ActiveRecord::Migration
  def self.up
    change_column :datasets, :data_size, :integer, :limit => 8
    change_column :dataset_versions, :data_size, :integer, :limit => 8
  end

  def self.down
    change_column :dataset_versions, :data_size, :integer
    change_column :datasets, :data_size, :integer
  end
end
