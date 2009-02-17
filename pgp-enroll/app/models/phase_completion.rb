class PhaseCompletion < ActiveRecord::Base
  belongs_to :user

  def self.phase_for(user)
    # For now, there are only two phases
    if user.phase_completions.any? { |pc| pc.phase == 'screening' }
      'preenrollment'
    else
      'screening'
    end
  end
end
