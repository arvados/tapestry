class PhaseCompletion < ActiveRecord::Base
  belongs_to :user
  validates_inclusion_of :phase, :in => %w(screening preenrollment), :message => "is invalid"

  def self.phase_for(user)
    # For now, there are only two phases
    if user.phase_completions.any? { |pc| pc.phase == 'screening' }
      'preenrollment'
    else
      'screening'
    end
  end
end
