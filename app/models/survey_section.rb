class SurveySection < ActiveRecord::Base
  has_many :survey_questions
  belongs_to :survey
end
