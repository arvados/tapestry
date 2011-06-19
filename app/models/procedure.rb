class Procedure < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

      belongs_to :ccr
      belongs_to :procedure_description
  
  def description
    if not procedure_description.nil? then 
      procedure_description.description
    else
      ''
    end
  end
end
