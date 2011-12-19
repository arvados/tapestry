class AddPhoneNumberToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :phone_number, :string, :default => ''
    add_column :user_versions, :phone_number, :string
  end

  def self.down
    remove_column :user_versions, :phone_number
    remove_column :users, :phone_number
  end
end
