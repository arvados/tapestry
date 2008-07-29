class EnrollmentStepCompletion < ActiveRecord::Base
  belongs_to :user
  belongs_to :enrollment_step

  validates_presence_of :user, :enrollment_step
end
