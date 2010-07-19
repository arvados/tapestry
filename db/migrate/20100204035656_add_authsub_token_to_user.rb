class AddAuthsubTokenToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :authsub_token, :string
  end

  def self.down
    remove_column :users, :authsub_token
  end
end
