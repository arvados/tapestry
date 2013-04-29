class AddTestFieldsToBulkMessage < ActiveRecord::Migration
  def self.up
    add_column :bulk_messages, :tested, :boolean, :default => false
    add_column :bulk_messages, :tested_at, :datetime, :default => nil
    add_column :bulk_message_versions, :tested, :boolean, :default => false
    add_column :bulk_message_versions, :tested_at, :datetime, :default => nil
  end

  def self.down
    remove_column :bulk_messages, :tested
    remove_column :bulk_messages, :tested_at
    remove_column :bulk_message_versions, :tested
    remove_column :bulk_message_versions, :tested_at
  end
end
