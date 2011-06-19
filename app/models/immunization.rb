class Immunization < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

      belongs_to :ccr
      belongs_to :immunization_name

  def name
    if not immunization_name.nil? then
      immunization_name.name
    else
      ''
    end
  end
end
