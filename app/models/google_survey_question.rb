class GoogleSurveyQuestion < ActiveRecord::Base
  belongs_to :google_survey
  validates_uniqueness_of :column, :scope => :google_survey_id
end
