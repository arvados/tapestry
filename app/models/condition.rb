class Condition < ActiveRecord::Base
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
