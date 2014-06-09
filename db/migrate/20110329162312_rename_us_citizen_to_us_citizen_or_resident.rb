class RenameUsCitizenToUsCitizenOrResident < ActiveRecord::Migration
  def self.up
    rename_column :screening_survey_responses, :us_citizen, :us_citizen_or_resident
  end

  def self.down
    rename_column :screening_survey_responses, :us_citizen_or_resident, :us_citizen
  end
end
