class Procedure < ActiveRecord::Base
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
