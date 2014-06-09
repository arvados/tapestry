class ChangeUsResidencyToResidency < ActiveRecord::Migration
  def self.up
    rename_column :screening_survey_responses, :us_citizen_or_resident, :citizen_or_resident
    rename_column :screening_survey_response_versions, :us_citizen_or_resident, :citizen_or_resident
    rename_column :residency_survey_responses, :us_resident, :resident
    rename_column :residency_survey_response_versions, :us_resident, :resident
    rename_column :residency_survey_responses, :can_travel_to_boston, :can_travel_to_pgphq
    rename_column :residency_survey_response_versions, :can_travel_to_boston, :can_travel_to_pgphq
  end

  def self.down
    rename_column :screening_survey_responses, :citizen_or_resident, :us_citizen_or_resident
    rename_column :screening_survey_response_versions, :citizen_or_resident, :us_citizen_or_resident
    rename_column :residency_survey_responses, :resident, :us_resident
    rename_column :residency_survey_response_versions, :resident, :us_resident
    rename_column :residency_survey_responses, :can_travel_to_pgphq, :can_travel_to_boston
    rename_column :residency_survey_response_versions, :can_travel_to_pgphq, :can_travel_to_boston
  end
end
