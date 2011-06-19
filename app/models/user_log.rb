class UserLog < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user
  belongs_to :enrollment_step

  validates_presence_of :user_id

  attr_accessible :user, :comment, :user_comment, :enrollment_step, :origin
 end
