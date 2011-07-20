class AddNonceIndexToNonce < ActiveRecord::Migration
  def self.up
    add_index :nonces, :nonce
  end

  def self.down
    remove_index :nonces, :nonce
  end
end
