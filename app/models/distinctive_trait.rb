class DistinctiveTrait < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  validates_presence_of :name, :rating
  belongs_to :user
end
