require 'test_helper'

class DistinctiveTraitTest < ActiveSupport::TestCase
  setup do
    @enrollment_step = Factory :enrollment_step
  end

  should "have a factory" do
    assert_valid Factory(:distinctive_trait)
  end

  should_validate_presence_of :name, :rating
  should_belong_to :user
end
