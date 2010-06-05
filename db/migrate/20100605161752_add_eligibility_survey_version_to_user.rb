class AddEligibilitySurveyVersionToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :eligibility_survey_version, :string
    self.set_v1_eligibility_survey_version
  end

  def self.set_v1_eligibility_survey_version
    execute 'UPDATE users u set eligibility_survey_version=\'v1\' where id in (select user_id from enrollment_step_completions where user_id=u.id and enrollment_step_id=8)'
  end

  def self.down
    remove_column :users, :eligibility_survey_version
  end
end
