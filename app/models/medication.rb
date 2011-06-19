class Medication < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

      belongs_to :ccr
      belongs_to :medication_name

  def name
    if not medication_name.nil? then 
      medication_name.name
    else
      ''
    end
  end
end
