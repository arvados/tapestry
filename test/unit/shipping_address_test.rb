require 'test_helper'

class ShippingAddressTest < ActiveSupport::TestCase
  should_eventually "test that gmaps is working properly - currently it has been deactivated in the model for for Rails.env == 'test'"
end
