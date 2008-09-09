class ExamResponse < ActiveRecord::Base
  belongs_to :user
  belongs_to :original_user, :class_name => 'User', :foreign_key => 'original_user_id'
  belongs_to :exam_version
  has_many   :question_responses

  def discard_for_retake!
    update_attributes!(
      :original_user_id => user_id,
      :user_id => nil)
  end
end
