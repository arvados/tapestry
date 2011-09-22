class UserLog < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user
  belongs_to :enrollment_step
  belongs_to :controlling_user, :class_name => 'User'

  validates_presence_of :user_id

  attr_accessible :user, :comment, :user_comment, :enrollment_step, :origin, :controlling_user
 end
