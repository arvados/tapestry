class AddDurationToEnrollmentStep < ActiveRecord::Migration
  def self.up
    add_column 'enrollment_steps', 'duration', :string
  end

  def self.down
    remove_column 'enrollment_steps', 'duration'
  end
end
