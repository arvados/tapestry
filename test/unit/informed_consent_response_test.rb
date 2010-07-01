require 'test_helper'

class InformedConsentResponseTest < ActiveSupport::TestCase
  context 'an informed consent response' do
    setup do
      @informed_consent_response = Factory(:informed_consent_response)
    end

    should_belong_to :user
    should_validate_presence_of :user_id

    should_allow_values_for :twin, 0, 1, 2
    should_allow_values_for :recontact, 0, 1

    should_not_allow_values_for :twin, 3, :message => 'must be Yes, No or Unsure'
    should_not_allow_values_for :recontact, 2, :message => 'must be Yes or No'

    should_not_allow_mass_assignment_of :user_id
  end
end
