class ExamQuestion < ActiveRecord::Base
  belongs_to :exam_version
  has_many   :answer_options
  has_many   :question_responses

  KINDS = %w(MULTIPLE_CHOICE CHECK_ALL)

  attr_accessible :kind, :ordinal, :question, :exam_version_id
  validates_inclusion_of :kind, :in => ExamQuestion::KINDS

  named_scope :ordered, { :order => 'ordinal' }

  def next_question
    exam_version.exam_questions.find(:first, :conditions => ['ordinal > ?', ordinal], :order => 'ordinal')
  end

  def last_in_exam?
    next_question.nil?
  end

  def correct_answer
    if kind == 'MULTIPLE_CHOICE'
      correct_answer_option = answer_options.detect(&:correct?)
      correct_answer_option.nil? ? nil : correct_answer_option.id.to_s
    elsif kind == 'CHECK_ALL'
      answer_options.select(&:correct?).map(&:id).sort.join(',')
    else
      nil
    end
  end
end
