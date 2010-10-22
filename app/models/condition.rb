class Condition < ActiveRecord::Base
      belongs_to :ccr
      belongs_to :condition_description

  def description
    condition_description.description
  end
end
