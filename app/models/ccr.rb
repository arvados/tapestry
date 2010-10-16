class Ccr < ActiveRecord::Base
      belongs_to :user
      has_one :demographic
      has_many :conditions
      has_many :immunizations
      has_many :allergies
      has_many :lab_test_results
      has_many :medications
      has_many :procedures
end
