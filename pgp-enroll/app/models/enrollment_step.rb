class EnrollmentStep < ActiveRecord::Base
  validates_presence_of :keyword, :ordinal, :title, :description 
end
