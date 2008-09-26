class ExamVersion < ActiveRecord::Base
  belongs_to :exam
  has_many   :exam_questions
  has_many   :exam_responses

  validates_presence_of :title, :description, :version

  named_scope :published, :conditions => [ 'published = ?', true ]
  named_scope :ordered,   :order => 'version'

  before_create :assign_version

  def question_count
    exam_questions.count
  end

  protected

  def assign_version
    self.version = exam.versions.count + 1
  end

end
