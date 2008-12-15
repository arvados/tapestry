class CreateResidencySurveyResponses < ActiveRecord::Migration
  def self.up
    create_table :residency_survey_responses do |t|
      t.references :user
      t.boolean    :us_resident
      t.string     :country
      t.boolean    :contact_when_pgp_opens_outside_us
      t.string     :zip
      t.boolean    :can_travel_to_boston
      t.boolean    :contact_when_boston_travel_facilitated
      t.timestamps
    end

    add_index 'residency_survey_responses', 'user_id'
  end

  def self.down
    remove_index 'residency_survey_responses', 'user_id'
    drop_table :residency_survey_responses
  end
end
