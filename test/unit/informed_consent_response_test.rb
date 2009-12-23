require 'test_helper'

class InformedConsentResponseTest < ActiveSupport::TestCase
  context 'an informed consent response' do
    setup do
      @informed_consent_response = Factory(:informed_consent_response)
    end

    should_belong_to :user
    should_validate_presence_of :user_id

    should_allow_values_for :twin, true, false
    should_allow_values_for :biopsy, true, false
    should_allow_values_for :recontact, true, false

    should_not_allow_values_for :twin, nil, :message => 'must be Yes or No'
    should_not_allow_values_for :biopsy, nil, :message => 'must be Yes or No'
    should_not_allow_values_for :recontact, nil, :message => 'must be Yes or No'

    should_not_allow_mass_assignment_of :user_id
  end
end
