class ExamVersion < ActiveRecord::Base
  belongs_to :exam
  has_many   :exam_questions
  has_many   :exam_responses

  validates_presence_of :title, :description, :version

  named_scope :published, :conditions => [ 'published = ?', true ]
end
