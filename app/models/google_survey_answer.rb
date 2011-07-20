class GoogleSurveyAnswer < ActiveRecord::Base
  belongs_to :google_survey
  belongs_to :nonce
  validates_uniqueness_of :column, :scope => :nonce_id
end
