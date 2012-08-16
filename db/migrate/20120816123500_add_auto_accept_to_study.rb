class AddAutoAcceptToStudy < ActiveRecord::Migration
  def self.up
    add_column :studies, :auto_accept, :boolean, :default => false
    update "update studies set auto_accept='f'";
  end

  def self.down
    remove_column :studies, :auto_accept
  end
end
