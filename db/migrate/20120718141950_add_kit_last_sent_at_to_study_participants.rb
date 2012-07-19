class AddKitLastSentAtToStudyParticipants < ActiveRecord::Migration
  def self.up
    add_column :study_participants, :kit_last_sent_at, :timestamp, :default => nil
    add_column :study_participant_versions, :kit_last_sent_at, :timestamp, :default => nil
  end

  def self.down
    remove_column :study_participant_versions, :kit_last_sent_at
    remove_column :study_participants, :kit_last_sent_at
  end
end
