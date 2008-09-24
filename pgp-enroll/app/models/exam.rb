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
    if versions.published.any?
      versions.published.ordered.last.title
    elsif versions.any?
      "#{versions.ordered.last.title} (Unpublished)"
    else
      'Untitled Exam'
    end
  end
end
