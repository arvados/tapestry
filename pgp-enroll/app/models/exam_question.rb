class ExamQuestion < ActiveRecord::Base
  belongs_to :exam_definition
  has_many   :question_responses
end

class MultipleChoiceExamQuestion < ExamQuestion
end

class CheckAllExamQuestion < ExamQuestion
end
