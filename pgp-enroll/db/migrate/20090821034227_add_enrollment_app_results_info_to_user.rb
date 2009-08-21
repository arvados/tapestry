class AddEnrollmentAppResultsInfoToUser < ActiveRecord::Migration
  def self.up
    add_column :users, "has_sequence", :boolean, :default => false, :null => false
    add_column :users, "has_sequence_explanation", :string
    add_column :users, "family_members_passed_exam", :text
  end

  def self.down
    remove_column :users, "has_sequence"
    remove_column :users, "has_sequence_explanation"
    remove_column :users, "family_members_passed_exam"
  end
end
