class AddParticipationUrlToStudy < ActiveRecord::Migration
  def self.up
    add_column :studies, :participation_url, :string, :default => nil
    add_column :study_versions, :participation_url, :string, :default => nil
  end

  def self.down
    remove_column :study_versions, :participation_url
    remove_column :studies, :participation_url
  end
end
