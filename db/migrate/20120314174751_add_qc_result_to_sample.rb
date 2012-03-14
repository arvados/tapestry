class AddQcResultToSample < ActiveRecord::Migration
  def self.up
    add_column :samples, :qc_result, :text
    add_column :sample_versions, :qc_result, :text
  end

  def self.down
    remove_column :sample_versions, :qc_result
    remove_column :samples, :qc_result
  end
end
