class AddTitleToStudyGuidePages < ActiveRecord::Migration
  def self.up
    add_column :study_guide_pages, :title, :string
  end

  def self.down
    remove_column :study_guide_pages, :title
  end
end
