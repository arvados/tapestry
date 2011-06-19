class EnrollmentStepCompletion < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user
  belongs_to :enrollment_step

  validates_presence_of :user, :enrollment_step
end
