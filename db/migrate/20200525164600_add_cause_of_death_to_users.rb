class AddCauseOfDeathToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :cause_of_death, :string, :default => nil
    add_column :user_versions, :cause_of_death, :string
  end

  def self.down
    remove_column :user_versions, :cause_of_death
    remove_column :users, :cause_of_death
  end
end
