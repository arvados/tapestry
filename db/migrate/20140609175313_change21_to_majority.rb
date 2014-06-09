class Change21ToMajority < ActiveRecord::Migration
  def self.up
    rename_column :screening_survey_responses, :age_21, :age_majority
    rename_column :screening_survey_response_versions, :age_21, :age_majority
  end

  def self.down
    rename_column :screening_survey_responses, :age_majority, :age_21
    rename_column :screening_survey_response_versions, :age_majority, :age_21
  end
end
