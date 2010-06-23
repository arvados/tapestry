class AddIdentityVerificationNotificationEnrollmentStep < ActiveRecord::Migration
  def self.up
    # Insert a new step to notify people about potential identity verification later in the process
    execute "INSERT INTO enrollment_steps (keyword, ordinal, title, description, duration) values ('identity_verification_notification',10,'Identity Verification','Identity Verification','1 minute')"
  end

  def self.down
    # Remove step
    execute "DELETE FROM enrollment_steps where ordinal=10"
  end
end
