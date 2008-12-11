class EnrollmentStep < ActiveRecord::Base
  validates_presence_of :keyword, :ordinal, :title, :description 

  has_many :enrollment_step_completions
  has_many :completers, :through => :enrollment_step_completions, :source => :user

  named_scope :ordered, { :order => 'ordinal' }

end
