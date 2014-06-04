class ResidencySurveyResponse < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  after_save :complete_enrollment_step
  validate :residency_validation

  attr_protected :user_id

  def complete_enrollment_step
    user = self.user.reload
    if user.residency_survey_response &&
       user.family_survey_response &&
       user.privacy_survey_response

      if not user.eligibility_survey_version then
        user.eligibility_survey_version = 'v1'
        user.save(:validate => false)
      end

      step = EnrollmentStep.find_by_keyword('screening_surveys')
      user.complete_enrollment_step(step)
    end
  end

  belongs_to :user
  validates_inclusion_of :us_resident, :in => [true, false], :message => "can't be blank"

  def eligible?
    us_resident && can_travel_to_boston
  end

  def waitlist_message
    if us_resident
      if !can_travel_to_boston
        I18n.t 'messages.waitlist.residency'
      end
    else
      I18n.t 'messages.waitlist.residency'
    end
  end

  private

  def residency_validation
    if (us_resident == true)
      require_attribute 'zip' do
        unless zip =~ APP_CONFIG['zip_validation']
          errors.add(:zip, I18n.t('activerecord.errors.models.user.attributes.zip.invalid'))
        end
        require_attribute 'can_travel_to_boston'
      end
    elsif (us_resident == false)
      require_attribute 'country'
    end
  end

  def require_attribute(attribute, message = "can't be blank")
    value = self.send(attribute)

    if value.nil? || value == ''
      errors.add(attribute, message)
    else
      yield if block_given?
    end
  end

end
