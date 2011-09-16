class Dataset < ActiveRecord::Base
  acts_as_versioned

  belongs_to :participant, :class_name => 'User'
end
