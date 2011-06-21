class DeviceType < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  validates_presence_of    :name
  validates_uniqueness_of  :name
end
