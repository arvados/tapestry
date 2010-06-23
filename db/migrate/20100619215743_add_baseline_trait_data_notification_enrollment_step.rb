class AddBaselineTraitDataNotificationEnrollmentStep < ActiveRecord::Migration
  def self.up
    # Insert a new step to notify people about the baseline trait collection later in the process
    execute "INSERT INTO enrollment_steps (keyword, ordinal, title, description, duration) values ('baseline_trait_collection_notification',9,'Baseline Trait Data','Baseline Trait Data','1 minute')"
  end

  def self.down
    # Remove step
    execute "DELETE FROM enrollment_steps where ordinal=9"
  end
end
