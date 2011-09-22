class SampleLog < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :sample
  belongs_to :actor, :class_name => "User"
  belongs_to :controlling_user, :class_name => "User"

  before_create :set_controlling_user

  private

  def set_controlling_user
    self.controlling_user ||= self.actor.controlling_user || self.actor if self.actor
    true
  end
end
