class EnrollmentStep < ActiveRecord::Base
  validates_presence_of :keyword, :ordinal, :title, :description 

  has_many :enrollment_step_completions
  has_many :completers, :through => :enrollment_step_completions, :source => :user

  scope :ordered, { :order => 'ordinal' }

  #FIXME test
  def duration_amount
    duration ? duration.split.first : ''
  end

  #FIXME test
  def duration_unit
    duration ? duration.split.last : ''
  end
end
