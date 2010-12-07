class UserLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :enrollment_step

  validates_presence_of :user_id

  attr_accessible :user, :comment, :user_comment, :enrollment_step, :origin
 end
