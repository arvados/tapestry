class AddEnrolledToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :enrolled, :datetime, :default => nil
  end

  def self.down
    remove_column :users, :enrolled
  end
end
