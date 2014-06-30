class ExamVersion < ActiveRecord::Base
  belongs_to :exam
  has_many   :exam_questions, :order => 'ordinal'
  has_many   :exam_responses
  has_many   :study_guide_pages

  validates_presence_of :title, :description, :ordinal

  validate :cannot_publish_without_questions

  scope :published, :conditions => [ 'published = ?', true ]
  scope :by_version, :order => 'version'

  before_create :assign_version

  def question_count
    exam_questions.count
  end

  def duplicate!
    new_version = self.clone(:include => { :exam_questions => :answer_options })
    new_version.published = false
    if new_version.save
      return new_version
    else
      raise new_version.errors.inspect
    end
  end

  def completed_by?(user)
    # Although this uses #select and #any? we only really expect one response set, since by retaking an exam the user attribute gets set to nil.
    exam_responses.for_user(user).select(&:correct?).any?
  end

  protected

  def assign_version
    maximum = ExamVersion.maximum('version', :conditions => ['exam_id = ?', self.exam_id]) || 0
    self.version = maximum + 1
  end

  def cannot_publish_without_questions
    if published && exam_questions.empty?
      errors.add :base, 'You cannot publish an exam without any questions in it.'
    end
  end

end
