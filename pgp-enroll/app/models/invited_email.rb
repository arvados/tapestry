class InvitedEmail < ActiveRecord::Base
  validates_presence_of :email

  INVITE_CODE = 'exome'

  def accept!
    update_attributes!({:accepted_at => Time.now})
  end

  named_scope :accepted, { :conditions => ['accepted_at is not null'] }
end
