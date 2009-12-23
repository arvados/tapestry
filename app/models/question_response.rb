class QuestionResponse < ActiveRecord::Base
  belongs_to :exam_response
  belongs_to :exam_question

  after_save :check_for_entrance_exam_completion
  before_validation :normalize_answer, :cache_correct

  named_scope :correct, { :conditions => { :correct => true } }

  def correct?
    cache_correct if read_attribute(:correct).nil?
    read_attribute(:correct)
  end

  protected

  def correct_answer?
    (exam_question && exam_question.correct_answer) ? (answer.to_s == exam_question.correct_answer.to_s) : false
  end

  def check_for_entrance_exam_completion
    if ContentArea.all.all? {|c| c.completed_by?(exam_response.user) }
      unless EnrollmentStep.find_by_keyword('content_areas').completers.include?(exam_response.user)
        exam_response.user.enrollment_step_completions.create({
          :enrollment_step => EnrollmentStep.find_by_keyword('content_areas'),
        })
      end
    end
  end

  def normalize_answer
    unless self.answer.blank?
      if self.exam_question.kind == 'CHECK_ALL'
        self.answer = self.answer.split(',').map(&:to_i).sort.join(',')
      end
    end

    true
  end

  def cache_correct
    write_attribute(:correct, correct_answer?)
    true
  end
end
