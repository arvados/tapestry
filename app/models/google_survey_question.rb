class GoogleSurveyQuestion < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :google_survey
  validates_uniqueness_of :column, :scope => :google_survey_id
end
