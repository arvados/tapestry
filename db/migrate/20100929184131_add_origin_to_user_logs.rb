class AddOriginToUserLogs < ActiveRecord::Migration
  def self.up
    add_column :user_logs, :origin, :string
  end

  def self.down
    remove_column :user_logs, :origin
  end
end
