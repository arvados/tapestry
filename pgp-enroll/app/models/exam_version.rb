class ExamVersion < ActiveRecord::Base
  belongs_to :exam
  has_many   :exam_questions
  has_many   :exam_responses

  validates_presence_of :title, :description

  named_scope :published, :conditions => [ 'published = ?', true ]
  named_scope :ordered,   :order => 'version'

  before_create :assign_version

  def question_count
    exam_questions.count
  end

  def duplicate!
    new_version = self.clone(:except  => [:published, :version],
                             :include => { :exam_questions => :answer_options })
    if new_version.save
      return new_version
    else
      raise new_version.errors.inspect
    end
  end

  protected

  def assign_version
    # self.version = exam.versions.max_by(&:version) + 1
    maximum = ExamVersion.maximum('version', :conditions => ['exam_id = ?', self.exam_id]) || 0
    self.version = maximum + 1
  end

end
