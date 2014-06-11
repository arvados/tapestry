class ChangeUsCitizenToCitizenInBaselineTraits < ActiveRecord::Migration
  def self.up
    rename_column :baseline_traits_surveys, :us_citizen, :citizen
    rename_column :baseline_traits_survey_versions, :us_citizen, :citizen
  end

  def self.down
    rename_column :baseline_traits_surveys, :citizen, :us_citizen
    rename_column :baseline_traits_survey_versions, :citizen, :us_citizen
  end
end
