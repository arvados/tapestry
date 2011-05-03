class Waitlist < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id

  scope :resubmitted, { :conditions => "resubmitted_at IS NOT NULL" }
  scope :not_resubmitted, { :conditions => "resubmitted_at IS NULL" }

  scope :ordered, { :order => 'created_at ASC' }
end
