class AddPledgeFieldToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :pledge, :integer
  end

  def self.down
    remove_column :users, :pledge
  end
end
