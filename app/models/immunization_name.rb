class ImmunizationName < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  has_many :immunizations
end
