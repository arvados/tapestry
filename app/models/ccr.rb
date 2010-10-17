class Ccr < ActiveRecord::Base
      belongs_to :user
      has_one :demographic, :dependent => :destroy
      has_many :conditions, :dependent => :destroy
      has_many :immunizations, :dependent => :destroy
      has_many :allergies, :dependent => :destroy
      has_many :lab_test_results, :dependent => :destroy
      has_many :medications, :dependent => :destroy
      has_many :procedures, :dependent => :destroy
end
