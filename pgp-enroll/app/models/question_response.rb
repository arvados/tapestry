class QuestionResponse < ActiveRecord::Base
  belongs_to :exam_response
  belongs_to :exam_question

  after_save :check_for_entrance_exam_completion
  before_validation :normalize_answer

  def correct?
    (exam_question && exam_question.correct_answer) ? (answer.to_s == exam_question.correct_answer.to_s_) : false
  end

  protected

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
  end
end
