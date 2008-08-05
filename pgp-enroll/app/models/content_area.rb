class ContentArea < ActiveRecord::Base
  has_many :exam_definitions

  validates_presence_of :title, :description
end
