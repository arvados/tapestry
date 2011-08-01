class SampleLog < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :sample
  belongs_to :actor, :class_name => "User"
end
