require 'test_helper'

class WaitlistTest < ActiveSupport::TestCase
  should belong_to :user
  should validate_presence_of :user_id

  should "have a valid factory" do
    assert_valid Factory(:waitlist)
  end

  should "only include waitlists with nil resubmitted_at in .not_resubmitted" do
    not_resubmitted = Factory(:waitlist, :resubmitted_at => nil)
    Factory(:waitlist, :resubmitted_at => Time.now)
    assert_equal [not_resubmitted], Waitlist.not_resubmitted
  end

  should "only include waitlists with non-nil resubmitted_at in .resubmitted" do
    Factory(:waitlist, :resubmitted_at => nil)
    resubmitted = Factory(:waitlist, :resubmitted_at => Time.now)
    assert_equal [resubmitted], Waitlist.resubmitted
  end

  should "sort by created_at when sent .ordered" do
    waitlist1 = Factory(:waitlist, :created_at => 1.day.ago)
    waitlist3 = Factory(:waitlist)
    waitlist2 = Factory(:waitlist, :created_at => 1.hour.ago)

    assert_equal [waitlist1, waitlist2, waitlist3], Waitlist.ordered
  end
end
