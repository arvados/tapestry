class InvitedEmail < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  validates_presence_of :email

  INVITE_CODE = 'exome'

  def accept!
    update_attributes!({:accepted_at => Time.now})
  end

  scope :accepted, { :conditions => ['accepted_at is not null'] }
end
