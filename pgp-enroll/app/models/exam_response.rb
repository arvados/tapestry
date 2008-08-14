class ExamResponse < ActiveRecord::Base
  belongs_to :user
  belongs_to :exam_definition
  has_many   :question_responses
end
