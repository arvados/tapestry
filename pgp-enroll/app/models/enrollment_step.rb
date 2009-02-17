class EnrollmentStep < ActiveRecord::Base
  validates_presence_of :keyword, :ordinal, :title, :description 
  validates_inclusion_of :phase, :in => %w(screening preenrollment)

  has_many :enrollment_step_completions
  has_many :completers, :through => :enrollment_step_completions, :source => :user

  named_scope :ordered, { :order => 'ordinal' }

  named_scope :for_phase, lambda { |phase| { :conditions => ['phase = ?', phase] } }

end
