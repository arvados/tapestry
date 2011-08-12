class GoogleSurveyAnswer < ActiveRecord::Base
  belongs_to :google_survey
  has_one :google_survey_question,
    :foreign_key => 'google_survey_id',
    :primary_key => :google_survey_id,
    :conditions => [' `column` = ? ', '#{self.column}']
  belongs_to :nonce
  validates_uniqueness_of :column, :scope => :nonce_id
end
