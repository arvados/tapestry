class AddIsDestroyedToSample < ActiveRecord::Migration
  def self.up
    add_column :samples, :is_destroyed, :datetime, :default => nil
  end

  def self.down
    remove_column :samples, :is_destroyed
  end
end
