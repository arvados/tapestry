class ExamResponse < ActiveRecord::Base
  belongs_to :user
  belongs_to :exam_definition
end
