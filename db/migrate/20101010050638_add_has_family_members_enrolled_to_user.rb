class AddHasFamilyMembersEnrolledToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :has_family_members_enrolled, :string
  end

  def self.down
    remove_column :users, :has_family_members_enrolled
  end
end
