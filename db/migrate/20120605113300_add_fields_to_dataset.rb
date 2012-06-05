class AddFieldsToDataset < ActiveRecord::Migration
  def self.up
    add_column :datasets, :creator_id, :integer
    add_column :dataset_versions, :creator_id, :integer
    add_column :datasets, :updater_id, :integer
    add_column :dataset_versions, :updater_id, :integer

    add_column :datasets, :released_to_participant, :boolean, :default => false
    add_column :dataset_versions, :released_to_participant, :boolean, :default => false

    add_column :datasets, :locator, :string, :default => ''
    add_column :dataset_versions, :locator, :string, :default => ''

    add_column :datasets, :sent_notification_at, :datetime, :default => nil
    add_column :dataset_versions, :sent_notification_at, :datetime, :default => nil
    add_column :datasets, :seen_by_participant_at, :datetime, :default => nil
    add_column :dataset_versions, :seen_by_participant_at, :datetime, :default => nil
    add_column :datasets, :published_at, :datetime, :default => nil
    add_column :dataset_versions, :published_at, :datetime, :default => nil
  end

  def self.down
    remove_column :datasets, :creator_id
    remove_column :dataset_versions, :creator_id
    remove_column :datasets, :updater_id
    remove_column :dataset_versions, :updater_id

    remove_column :datasets, :released_to_participant
    remove_column :dataset_versions, :released_to_participant

    remove_column :datasets, :locator
    remove_column :dataset_versions, :locator

    remove_column :datasets, :sent_notification_at
    remove_column :dataset_versions, :sent_notification_at
    remove_column :datasets, :seen_by_participant_at
    remove_column :dataset_versions, :seen_by_participant_at
    remove_column :datasets, :published_at
    remove_column :dataset_versions, :published_at
  end
end
