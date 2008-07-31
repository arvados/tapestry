class ExamDefinition < ActiveRecord::Base
  belongs_to :parent, :class_name => 'ExamDefinition'
end
