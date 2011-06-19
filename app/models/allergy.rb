class Allergy < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

      belongs_to :ccr
      belongs_to :allergy_description

  def description
    if not allergy_description.nil? then 
      allergy_description.description
    else
      ''
    end
  end
end
