class Survey < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  has_many :survey_sections
end
