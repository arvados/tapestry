class UserLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :enrollment_step
  attr_accessible :user, :comment, :enrollment_step
 end
