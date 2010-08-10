class AddEnrollmentAcceptedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :enrollment_accepted, :datetime, :default => nil
  end

  def self.down
    remove_column :users, :enrollment_accepted
  end
end
