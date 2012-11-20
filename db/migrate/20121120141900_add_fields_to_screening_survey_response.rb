class AddFieldsToScreeningSurveyResponse < ActiveRecord::Migration
  def self.up
    add_column :screening_survey_responses, :twin_name, :string, :default => nil
    add_column :screening_survey_responses, :twin_email, :string, :default => nil
  end

  def self.down
    remove_column :screening_survey_responses, :twin_name
    remove_column :screening_survey_responses, :twin_email
  end
end
