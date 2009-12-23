class Waitlist < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id

  named_scope :resubmitted, { :conditions => "resubmitted_at IS NOT NULL" }
  named_scope :not_resubmitted, { :conditions => "resubmitted_at IS NULL" }

  named_scope :ordered, { :order => 'created_at ASC' }
end
