class ContentArea < ActiveRecord::Base
  has_many :exams

  validates_presence_of :title, :description
end
