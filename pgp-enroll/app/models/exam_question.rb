class ExamQuestion < ActiveRecord::Base
  belongs_to :exam_version
  has_many   :answer_options

  KINDS = %w(MULTIPLE_CHOICE CHECK_ALL)

  attr_accessible :kind, :ordinal, :question
  validates_inclusion_of :kind, :in => ExamQuestion::KINDS

  def next_question
    exam_version.exam_questions.find(:first, :conditions => ['ordinal > ?', ordinal], :order => 'ordinal')
  end

  def last_in_exam?
    next_question.nil?
  end
end
