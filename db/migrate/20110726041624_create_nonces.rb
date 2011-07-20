class CreateNonces < ActiveRecord::Migration
  def self.up
    create_table :nonces do |t|
      t.references :owner
      t.string :nonce
      t.timestamp :created_at
      t.timestamp :used_at

      t.timestamps
    end
  end

  def self.down
    drop_table :nonces
  end
end
