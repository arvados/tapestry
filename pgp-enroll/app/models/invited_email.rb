class InvitedEmail < ActiveRecord::Base
  validates_presence_of :email

  def accept!
    update_attributes!({:accepted_at => Time.now})
  end
end
