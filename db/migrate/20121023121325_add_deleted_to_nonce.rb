class AddDeletedToNonce < ActiveRecord::Migration
  def self.up
    add_column :nonces, :deleted, :datetime, :default => nil
  end

  def self.down
    remove_column :nonces, :deleted
  end
end
