class Exam < ActiveRecord::Base
  has_many :versions, :class_name => 'ExamVersion'
  has_one :published_version, :class_name => 'ExamVersion'
  belongs_to :content_area

  def version_for(user)
    versions.find :first,
      :conditions => [ 'created_at < ? and published = ?', user.created_at, true ],
      :order => 'created_at DESC'
  end

  def version_for!(user)
    raise ActiveRecord::RecordNotFound unless version_for(user)
  end

  def title
    get_versioned_attribute(:title, 'Untitled Exam')
  end

  def description
    get_versioned_attribute(:description, 'Unpublished Exam')
  end

  private

  def get_versioned_attribute(attribute, default)
    if versions.published.any?
      versions.published.ordered.last.send(attribute)
    elsif versions.any?
      "#{versions.ordered.last.send(attribute)} (Unpublished)"
    else
      default
    end
  end
end
