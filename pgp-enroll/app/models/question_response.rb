class QuestionResponse < ActiveRecord::Base
  belongs_to :exam_response
  belongs_to :exam_question

  def correct?
    answer.to_s == exam_question.correct_answer.to_s
  end
end
