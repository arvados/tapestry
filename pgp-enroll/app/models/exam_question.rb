class ExamQuestion < ActiveRecord::Base
  belongs_to :exam_version
  has_many   :answer_options

  def next_question
    exam_version.exam_questions.find(:first, :conditions => ['ordinal > ?', ordinal], :order => 'ordinal')
  end

  def last_in_exam?
    next_question.nil?
  end
end
