class SampleLog < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :sample
  belongs_to :actor, :class_name => "User"
  belongs_to :controlling_user, :class_name => "User"

  before_create :set_controlling_user

  def news_feed_title
    "#{self.sample.material} sample #{self.sample.crc_id_s}"
  end

  def news_feed_summary
    s = self.comment
    if self.actor.researcher
      s << " (#{self.actor.researcher_affiliation})"
    elsif self.actor.hex
      s << " (#{self.actor.hex})"
    end
    s
  end

  def news_feed_link_to
    self.sample
  end

  private

  def set_controlling_user
    self.controlling_user ||= self.actor.controlling_user || self.actor if self.actor
    true
  end
end
