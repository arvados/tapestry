class UnusedKitName < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  def self.random
    name = self.first(:order => 'RAND()')
    name = '' if name.nil? 
    return name
  end

end
