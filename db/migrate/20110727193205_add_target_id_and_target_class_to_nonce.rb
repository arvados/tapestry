class AddTargetIdAndTargetClassToNonce < ActiveRecord::Migration
  def self.up
    add_column :nonces, :target_id, :integer
    add_column :nonces, :target_class, :string
  end

  def self.down
    remove_column :nonces, :target_class
    remove_column :nonces, :target_id
  end
end
