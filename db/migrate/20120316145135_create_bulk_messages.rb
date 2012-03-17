class CreateBulkMessages < ActiveRecord::Migration
  def self.up
    create_table :bulk_messages do |t|
      t.string :subject
      t.text :body

      t.boolean :sent, :default => false
      t.timestamp :sent_at, :default => nil

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    BulkMessage.create_versioned_table
  end

  def self.down
    BulkMessage.drop_versioned_table
    drop_table :bulk_messages
  end
end
