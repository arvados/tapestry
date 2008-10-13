class ContentArea < ActiveRecord::Base
  has_many :exams

  validates_presence_of :title, :description

  named_scope :ordered, {}

  def completed_by?(user)
    exams.all? do |exam|
      exam.version_for(user) && exam.version_for(user).completed_by?(user)
    end
  end

  def self.current_for(user)
    Exam.current_for(user).content_area if Exam.current_for(user)
  end
end
