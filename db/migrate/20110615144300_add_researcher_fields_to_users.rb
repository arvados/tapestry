class AddResearcherFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :researcher, :boolean, :default => false
    add_column :users, :researcher_affiliation, :string, :default => ''
    add_column :users, :researcher_onirb, :boolean, :default => false
  end

  def self.down
    remove_column :users, :researcher
    remove_column :users, :researcher_affiliation
    remove_column :users, :researcher_onirb
  end
end
