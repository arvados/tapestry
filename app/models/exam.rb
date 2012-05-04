class Exam < ActiveRecord::Base
  has_many :versions, :class_name => 'ExamVersion'
  belongs_to :content_area

  def ordinal
    if versions.any?
      versions.by_version.last.ordinal
    else
      1
    end
  end

  def self.ordered
    Exam.all.sort_by(&:ordinal)
  end

  def current()
    version_for(nil)
  end

  def version_for(user)
    versions.where('published = ?', true).order('version DESC').first
  end

  def version_for!(user)
    raise ActiveRecord::RecordNotFound unless version_for(user)
    version_for(user)
  end

  def title
    get_versioned_attribute(:title, 'Untitled Exam')
  end

  def description
    get_versioned_attribute(:description, 'Unpublished Exam')
  end

  def any_version_completed_by?(user)
    versions.find(:all, :conditions => [ 'published = ?', true ],:order => 'version DESC').each do |version|
      return true if version.completed_by?(user)
    end
    return false
  end

  def completed_by?(user)
    version_for(user) && version_for(user).completed_by?(user)
  end

  def self.current_for(user)
    ordered.detect do |exam|
      exam.version_for(user) && !exam.completed_by?(user)
    end
  end

  private

  def get_versioned_attribute(attribute, default)
    if versions.published.any?
      versions.published.by_version.last.send(attribute)
    elsif versions.any?
      "#{versions.by_version.last.send(attribute)} (Unpublished)"
    else
      default
    end
  end
end
