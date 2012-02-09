class ExamResponse < ActiveRecord::Base
  belongs_to :user
  belongs_to :original_user, :class_name => 'User', :foreign_key => 'original_user_id'
  belongs_to :exam_version
  has_many   :question_responses

  scope :for_user, lambda { |user| { :conditions => ['user_id = ?', user.id ] } }
  # The way in which old exam responses are retained is a bit braindead. This scope returns all exam responses for a given user.
  scope :all_for_user, lambda { |user| { :conditions => ['user_id = ? or original_user_id = ?', user.id, user.id ] } }

  def discard_for_retake!
    # why does update_attributes!({:original_user_id => user_id, :user_id => nil}) not work in test?
    connection.update("update exam_responses set original_user_id = #{user_id}, user_id = null where exam_responses.id = #{id}")
    reload
  end

  def response_count
    question_responses.count
  end

  def correct_response_count
    question_responses.correct.size
  end

  def correct?
    correct_response_count == exam_version.question_count
  end
end
