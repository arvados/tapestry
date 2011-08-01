class UnusedKitName < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version


  def self.random
    self.first(:order => 'RAND()')
  end

end
