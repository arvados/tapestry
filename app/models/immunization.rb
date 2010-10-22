class Immunization < ActiveRecord::Base
      belongs_to :ccr
      belongs_to :immunization_name

  def name
    immunization_name.name
  end
end
