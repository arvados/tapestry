class SurveyQuestion < ActiveRecord::Base
  has_many :survey_answer_choices
  belongs_to :survey_sections
end
