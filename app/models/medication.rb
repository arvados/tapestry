class Medication < ActiveRecord::Base
      belongs_to :ccr
      belongs_to :medication_name

  def name
    medication_name.name
  end
end
