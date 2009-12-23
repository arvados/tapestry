class AddPhrProfileNameToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :phr_profile_name, :string
  end

  def self.down
    remove_column :users, :phr_profile_name
  end
end
