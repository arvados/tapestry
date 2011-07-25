class CreateStudyParticipants < ActiveRecord::Migration
  def self.up
    create_table :study_participants do |t|
      t.references :user
      t.references :study
      t.integer :status, :default => 0

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    add_index :study_participants, [:user_id, :study_id], :unique => true
    StudyParticipant.create_versioned_table
  end

  def self.down
    StudyParticipant.drop_versioned_table
    drop_table :study_participants
  end
end
