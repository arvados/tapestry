class EnrollmentStep < ActiveRecord::Base
  validates_presence_of :keyword, :order, :title, :description 
end
