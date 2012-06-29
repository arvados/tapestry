class AddRemoveDataAndDestroySamplesToRemovalRequests < ActiveRecord::Migration
  def self.up
    change_table(:removal_requests) do |t|
      t.boolean :remove_data, :default => false
      t.boolean :destroy_samples, :default => false
      t.references :fulfilled_by, :default => nil
      t.timestamp :fulfilled_at, :default => nil
      t.text :admin_notes
      t.timestamp :deleted_at
    end
    RemovalRequest.create_versioned_table
  end

  def self.down
    RemovalRequest.drop_versioned_table
    remove_column :removal_requests, :deleted_at
    remove_column :removal_requests, :admin_notes
    remove_column :removal_requests, :fulfilled_at
    remove_column :removal_requests, :fulfilled_by_id
    remove_column :removal_requests, :destroy_samples
    remove_column :removal_requests, :remove_data
  end
end
