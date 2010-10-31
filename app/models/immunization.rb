class Immunization < ActiveRecord::Base
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
