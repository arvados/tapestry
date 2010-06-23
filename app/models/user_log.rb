class UserLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :enrollment_step

  validates_presence_of :user_id

  attr_accessible :user, :comment, :enrollment_step
 end
