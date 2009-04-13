class EnrollmentStep < ActiveRecord::Base
end

class EnrollmentStepCompletion < ActiveRecord::Base
  belongs_to :user
  belongs_to :enrollment_step
end

class User < ActiveRecord::Base
  has_many :enrollment_step_completions
  has_many :completed_enrollment_steps, :through => :enrollment_step_completions, :source => :enrollment_step
end

class FillInEligibilityScreeningResultsEnrollmentStep < ActiveRecord::Migration
  def self.up
    eligibility_screening_results_step = EnrollmentStep.find_by_keyword('eligibility_screening_results')
    User.all.each do |user|
      if user.completed_enrollment_steps.any? && user.completed_enrollment_steps.map(&:ordinal).max > eligibility_screening_results_step.ordinal
        EnrollmentStepCompletion.create(:user_id => user.id, :enrollment_step_id => eligibility_screening_results_step.id)
      end
    end
  end

  def self.down
  end
end
