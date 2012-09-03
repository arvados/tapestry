class KitLog < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :kit
  belongs_to :actor, :class_name => "User"
  belongs_to :controlling_user, :class_name => "User"

  before_create :set_controlling_user

  def news_feed_title
    "Collection kit \"#{self.kit.name}\""
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
    self.kit
  end

  def <=>(b)
    cmp = self.created_at <=> b.created_at
    cmp = self.id <=> b.id if cmp == 0
    cmp
  end

  private

  def set_controlling_user
    self.controlling_user ||= self.actor.controlling_user || self.actor if self.actor
    true
  end
end
