class AnswerOption < ActiveRecord::Base
  belongs_to :exam_question
  has_many :question_responses
end
