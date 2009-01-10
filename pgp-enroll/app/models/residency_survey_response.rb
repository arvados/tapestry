class ResidencySurveyResponse < ActiveRecord::Base
  belongs_to :user
  validates_inclusion_of :us_resident, :in => [true, false], :message => "can't be blank"

  def eligible?
    us_resident && can_travel_to_boston
  end

  def validate
    if (us_resident == true)
      require_attribute 'zip' do
        require_attribute 'can_travel_to_boston'
        require_attribute 'contact_when_boston_travel_facilitated' unless can_travel_to_boston
      end
    elsif (us_resident == false)
      require_attribute 'country' do
        require_attribute 'contact_when_pgp_opens_outside_us'
      end
    end
  end

  def waitlist_message
    if us_resident
      if !can_travel_to_boston
        if contact_when_boston_travel_facilitated
          return 'We will contact you when travel to Boston can be facilitated by the PGP.  Thank you for your interest!'
        else
          return 'Thank you for your interest in participating in the PGP.  If at some point in the future you are able to participate, please let us know!'
        end
      end
    else
      if contact_when_pgp_opens_outside_us
        return 'We will contact you when the Personal Genome Project opens enrollment to individuals living outside the United States.  Thank you for your interest!'
      else
        return 'Thank you for your interest in participating in the PGP.  If at some point in the future you are able to participate, please let us know!'
      end
    end

    nil
  end

  private

  def require_attribute(attribute, message = "can't be blank")
    value = self.send(attribute)

    if value.nil? || value == ''
      errors.add(attribute, message)
    else
      yield if block_given?
    end
  end
end
