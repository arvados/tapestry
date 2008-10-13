class ExamResponse < ActiveRecord::Base
  belongs_to :user
  belongs_to :original_user, :class_name => 'User', :foreign_key => 'original_user_id'
  belongs_to :exam_version
  has_many   :question_responses

  # after_save :check_for_entrance_exam_completion

  named_scope :for_user, lambda { |user| { :conditions => ['user_id = ?', user ] } }

  def discard_for_retake!
    update_attributes!(
      :original_user_id => user_id,
      :user_id => nil)
  end

  def response_count
    question_responses.count
  end

  def correct_response_count
    question_responses.select(&:correct?).size
  end

  def correct?
    correct_response_count == exam_version.exam_questions.size
  end
end
