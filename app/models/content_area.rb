class ContentArea < ActiveRecord::Base
  has_many :exams

  validates_presence_of :title, :description

  scope :ordered, { :order => 'ordinal' }

  def any_version_completed_by?(user)
    exams.all? do |exam|
      !exam.version_for(user) || (
        exam.version_for(user) && exam.any_version_completed_by?(user)
      )
    end
  end

  def completed_by?(user)
    exams.all? do |exam|
      !exam.version_for(user) || (
        exam.version_for(user) && exam.version_for(user).completed_by?(user)
      )
    end
  end

  def self.current_for(user)
    ordered.detect do |area|
      ! area.any_version_completed_by?(user)
    end
  end
end
