class CreateBulkMessageRecipients < ActiveRecord::Migration
  def self.up
    create_table :bulk_message_recipients do |t|
      t.references :bulk_message
      t.references :user

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :bulk_message_recipients, :user_id
    add_index :bulk_message_recipients, :bulk_message_id
    BulkMessageRecipient.create_versioned_table
  end

  def self.down
    BulkMessageRecipient.drop_versioned_table
    remove_index :bulk_message_recipients, :user_id
    remove_index :bulk_message_recipients, :bulk_message_id
    drop_table :bulk_message_recipients
  end
end
