class AddUserCommentToUserLogs < ActiveRecord::Migration
  def self.up
    add_column :user_logs, :user_comment, :string, :default => nil
  end

  def self.down
    remove_column :user_logs, :user_comment, :default => nil
  end
end
