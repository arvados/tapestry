class ExamQuestion < ActiveRecord::Base
  belongs_to :exam_definition
  has_many   :answer_options

  def next_question
    exam_definition.exam_questions.find(:first, :conditions => ['ordinal > ?', ordinal])
  end

  def last_in_exam?
    next_question.nil?
  end
end
