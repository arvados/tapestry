class Waitlist < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user
  validates_presence_of :user_id

  scope :resubmitted, { :conditions => "resubmitted_at IS NOT NULL" }
  scope :not_resubmitted, { :conditions => "resubmitted_at IS NULL" }

  scope :ordered, { :order => 'created_at ASC' }
end
