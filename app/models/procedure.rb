class Procedure < ActiveRecord::Base
      belongs_to :ccr
      belongs_to :procedure_description
  
  def description
    procedure_description.description
  end
end
