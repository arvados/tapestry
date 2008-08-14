class ExamQuestion < ActiveRecord::Base
  belongs_to :exam_definition
  has_many   :answer_options
end

class MultipleChoiceExamQuestion < ExamQuestion
end

class CheckAllExamQuestion < ExamQuestion
end
