class GoogleSurveyAnswer < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :google_survey
  has_one :google_survey_question,
    :foreign_key => 'google_survey_id',
    :primary_key => :google_survey_id,
    :conditions => [' `column` = ? ', '#{self.column}']
  belongs_to :nonce
  validates_uniqueness_of :column, :scope => :nonce_id
end
