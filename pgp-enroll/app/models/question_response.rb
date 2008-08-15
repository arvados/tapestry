class QuestionResponse < ActiveRecord::Base
  belongs_to :exam_response
  belongs_to :answer_option

  named_scope :correct,   :include => :answer_option, :conditions => ['answer_options.correct = ?', true]
  named_scope :incorrect, :include => :answer_option, :conditions => ['answer_options.correct = ?', false]
end
