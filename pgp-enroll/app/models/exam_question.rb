class ExamQuestion < ActiveRecord::Base
  QUESTION_KINDS = %w(multiple_choice check_all)

  belongs_to :exam_definition
end
