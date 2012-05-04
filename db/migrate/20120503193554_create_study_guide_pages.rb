class CreateStudyGuidePages < ActiveRecord::Migration
  def self.up
    create_table :study_guide_pages do |t|
      t.references :exam_version
      t.integer :ordinal
      t.text :contents

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    StudyGuidePage.create_versioned_table
  end

  def self.down
    StudyGuidePage.drop_versioned_table
    drop_table :study_guide_pages
  end
end
