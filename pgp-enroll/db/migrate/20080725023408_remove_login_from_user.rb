class RemoveLoginFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :login
  end

  def self.down
    add_column :users, :login, :string, :limit => 40
  end
end
