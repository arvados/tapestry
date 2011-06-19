class SurveyQuestion < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  has_many :survey_answer_choices
  belongs_to :survey_sections
end
