class QuestionResponse < ActiveRecord::Base
  belongs_to :exam_response
  belongs_to :answer_option
end
