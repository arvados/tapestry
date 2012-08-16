class FixDurationForEnrollmentApplicationResultsEnrollmentStep < ActiveRecord::Migration
  def self.up
    update "update enrollment_steps set duration='3-4 days' where keyword='enrollment_application_results'";
  end

  def self.down
    update "update enrollment_steps set duration='1-2 months' where keyword='enrollment_application_results'";
  end
end
