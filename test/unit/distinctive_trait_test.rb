require 'test_helper'

class DistinctiveTraitTest < ActiveSupport::TestCase
  setup do
    @enrollment_step = Factory :enrollment_step
  end

  should "have a factory" do
    assert_valid Factory(:distinctive_trait)
  end

  should validate_presence_of :name
  should validate_presence_of :rating
  should belong_to :user
end
