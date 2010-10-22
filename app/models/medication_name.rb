class MedicationName < ActiveRecord::Base
  has_many :medications
end
