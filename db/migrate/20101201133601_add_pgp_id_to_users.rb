class AddPgpIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :pgp_id, :string, :unique => true
  end

  def self.down
    remove_column :users, :pgp_id
  end
end
