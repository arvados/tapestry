class RemoveEnrollmentQueue < ActiveRecord::Migration
  def self.up
    # Remove enrollment queue step
    execute "DELETE FROM enrollment_steps where ordinal=6"
    execute "UPDATE enrollment_steps set ordinal=ordinal-1 where ordinal>6"
  end

  def self.down
    # Restore deleted steps
    execute "UPDATE enrollment_steps set ordinal=ordinal+1 where ordinal>=6"
    execute "INSERT INTO enrollment_steps (duration, keyword, ordinal, title, description) values ('4-6 weeks','enrollment_queue',6,'Enrollment Queue','Enrollment Queue')"
  end
end
