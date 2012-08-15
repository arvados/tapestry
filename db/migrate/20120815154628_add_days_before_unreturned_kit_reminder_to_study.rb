class AddDaysBeforeUnreturnedKitReminderToStudy < ActiveRecord::Migration
  def self.up
    add_column :studies, :days_before_unreturned_kit_reminder, :integer, :default => 21
    add_column :study_versions, :days_before_unreturned_kit_reminder, :integer, :default => 21
  end

  def self.down
    remove_column :study_versions, :days_before_unreturned_kit_reminder
    remove_column :studies, :days_before_unreturned_kit_reminder
  end
end
