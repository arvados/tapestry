class GoogleSurveyBypass < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user
  belongs_to :google_survey

  attr_protected :user_id
  attr_protected :google_survey_id

  before_create :generate_token

  protected

  def generate_token
    self.token = loop do
      random_token = SecureRandom.hex(20)
      break random_token unless GoogleSurveyBypass.exists?(:token => random_token)
    end
  end
end
