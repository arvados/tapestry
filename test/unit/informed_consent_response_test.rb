require 'test_helper'

class InformedConsentResponseTest < ActiveSupport::TestCase
  context 'an informed consent response' do
    setup do
      @informed_consent_response = Factory(:informed_consent_response)
    end

    should belong_to :user
    should validate_presence_of :user_id

    should_allow_values_for :twin, 0, 1, 2
    should_allow_values_for :recontact, 0, 1

    should_not_allow_values_for :twin, 3, :message => 'Please indicate whether you have an identical twin.'
    should_not_allow_values_for :recontact, 2, :message => 'Please indicate whether you are willing to be recontacted.'

    should_not allow_mass_assignment_of :user_id
  end
end
