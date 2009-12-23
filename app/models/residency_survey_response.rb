class ResidencySurveyResponse < ActiveRecord::Base
  after_save :complete_enrollment_step
  validate :zip_is_5_characters_if_us_resident
  attr_protected :user_id

  def complete_enrollment_step
    user = self.user.reload
    if user.residency_survey_response &&
       user.family_survey_response &&
       user.privacy_survey_response

      step = EnrollmentStep.find_by_keyword('screening_surveys')
      user.complete_enrollment_step(step)
    end
  end

  belongs_to :user
  validates_inclusion_of :us_resident, :in => [true, false], :message => "can't be blank"

  def eligible?
    us_resident && can_travel_to_boston
  end

  def validate
    if (us_resident == true)
      require_attribute 'zip' do
        require_attribute 'can_travel_to_boston'
      end
    elsif (us_resident == false)
      require_attribute 'country'
    end
  end

  def waitlist_message
    if us_resident
      if !can_travel_to_boston
        return 'Thank you for your interest in participating in the PGP.  If at some point in the future you are able to participate, please let us know!'
      end
    else
      return 'Thank you for your interest in participating in the PGP.  If at some point in the future you are able to participate, please let us know!'
    end

    nil
  end

  private

  def zip_is_5_characters_if_us_resident
    if us_resident
      unless zip =~ /\d{5}/
        errors.add(:zip, 'must be 5 numeric digits')
      end
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
