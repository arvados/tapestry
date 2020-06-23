class GoogleSurveyReminder < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user
  belongs_to :google_survey

  attr_protected :last_sent_at
  attr_protected :user_id

end
