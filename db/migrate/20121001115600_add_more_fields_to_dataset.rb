class AddMoreFieldsToDataset < ActiveRecord::Migration
  def self.up
    add_column :datasets, :published_anonymously_at, :datetime, :default => nil
    add_column :dataset_versions, :published_anonymously_at, :datetime, :default => nil
  end

  def self.down
    remove_column :datasets, :published_anonymously_at
    remove_column :dataset_versions, :published_anonymously_at
  end
end
