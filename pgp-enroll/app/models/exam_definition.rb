class ExamDefinition < ActiveRecord::Base
  belongs_to :parent, :class_name => 'ExamDefinition', :foreign_key => 'parent_id'
  has_one    :child,  :class_name => 'ExamDefinition', :foreign_key => 'parent_id'
  belongs_to :content_area

  validates_presence_of :content_area, :title, :description

  def version
    parent.nil? ? 1 : parent.version + 1
  end
end
