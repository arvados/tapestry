class CreateRemovalRequests < ActiveRecord::Migration
  def self.up
    create_table :removal_requests do |t|
      t.references :user
      t.text :items_to_remove
      t.timestamp :created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :removal_requests
  end
end
