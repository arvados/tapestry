class Allergy < ActiveRecord::Base
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
