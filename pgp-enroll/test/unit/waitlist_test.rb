require 'test_helper'

class WaitlistTest < ActiveSupport::TestCase
  should_belong_to :user
  should_validate_presence_of :user_id

  should "have a valid factory" do
    assert_valid Factory(:waitlist)
  end
end
