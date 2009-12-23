class AddIndexesForFamilyAndPrivacySurveyUserFks < ActiveRecord::Migration
  def self.up
    add_index 'family_survey_responses', 'user_id'
    add_index 'privacy_survey_responses', 'user_id'
  end

  def self.down
    remove_index 'family_survey_responses', 'user_id'
    remove_index 'privacy_survey_responses', 'user_id'
  end
end
