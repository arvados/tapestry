class RemoveQuestion3And6FromResidencySurvey < ActiveRecord::Migration
  def self.up
    remove_column :residency_survey_responses, 'contact_when_pgp_opens_outside_us'
    remove_column :residency_survey_responses, 'contact_when_boston_travel_facilitated'
  end

  def self.down
    add_column :residency_survey_responses, "contact_when_pgp_opens_outside_us", :boolean
    add_column :residency_survey_responses, "contact_when_boston_travel_facilitated", :boolean
  end
end
