class ResidencySurveyResponse < ActiveRecord::Base
  belongs_to :user
  validates_inclusion_of :us_resident, :in => [true, false], :message => "can't be blank"

  def eligible?
    us_resident && can_travel_to_boston
  end

  def validate
    if us_resident
      require_attribute 'zip' do
        require_attribute 'can_travel_to_boston'
        require_attribute 'contact_when_boston_travel_facilitated' unless can_travel_to_boston
      end
    else
      require_attribute 'country' do
        require_attribute 'contact_when_pgp_opens_outside_us'
      end
    end
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
