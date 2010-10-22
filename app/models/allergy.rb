class Allergy < ActiveRecord::Base
      belongs_to :ccr
      belongs_to :allergy_description

  def description
    allergy_description.description
  end
end
