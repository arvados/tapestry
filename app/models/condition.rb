class Condition < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

      belongs_to :ccr
      belongs_to :condition_description

  def description
    if not condition_description.nil? then 
      condition_description.description
    else
      ''
    end
  end
end
