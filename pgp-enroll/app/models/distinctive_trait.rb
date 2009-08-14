class DistinctiveTrait < ActiveRecord::Base
  validates_presence_of :name, :rating
  belongs_to :user
end
