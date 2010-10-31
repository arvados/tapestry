class Medication < ActiveRecord::Base
      belongs_to :ccr
      belongs_to :medication_name

  def name
    if not medication_name.nil? then 
      medication_name.name
    else
      ''
    end
  end
end
