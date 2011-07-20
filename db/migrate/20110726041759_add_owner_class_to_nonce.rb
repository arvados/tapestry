class AddOwnerClassToNonce < ActiveRecord::Migration
  def self.up
    add_column :nonces, :owner_class, :string
  end

  def self.down
    remove_column :nonces, :owner_class
  end
end
