class ChangeFamilyQuestionnaireResponseChildAgeToChildBirthYear < ActiveRecord::Migration
  def self.up
    rename_column :family_survey_responses, :youngest_child_age, :youngest_child_birth_year
  end

  def self.down
    rename_column :family_survey_responses, :youngest_child_birth_year, :youngest_child_age
  end
end
