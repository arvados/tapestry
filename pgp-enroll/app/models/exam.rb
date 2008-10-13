class Exam < ActiveRecord::Base
  has_many :versions, :class_name => 'ExamVersion'
  belongs_to :content_area

  # after_create :create_initial_version

  named_scope :ordered, {}

  def version_for(user)
    versions.find :first,
      :conditions => [ 'created_at < ? and published = ?', user.created_at, true ],
      :order => 'created_at DESC'
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
      versions.published.ordered.last.send(attribute)
    elsif versions.any?
      "#{versions.ordered.last.send(attribute)} (Unpublished)"
    else
      default
    end
  end

  # def create_initial_version
  #   versions.create({
  #     :title       => 'New Exam',
  #     :description => 'New Exam Description'
  #   })
  # end
end
