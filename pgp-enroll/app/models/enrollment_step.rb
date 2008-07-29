class EnrollmentStep < ActiveRecord::Base
  validates_presence_of :keyword, :ordinal, :title, :description 

  has_many :enrollment_step_completions
  has_many :completers, :through => :enrollment_step_completions, :source => :user

  def self.next_for(user)
    last_step_completed = user.last_completed_enrollment_step

    if last_step_completed.nil?
      first
    else
      find :first, :conditions => ['ordinal > ?', last_step_completed.ordinal]
    end
  end
end
