require 'test_helper'

class InvitedEmailTest < ActiveSupport::TestCase
  context "an invited email" do
    setup do
      @invited_email = Factory(:invited_email)
    end

    should "be valid" do
      assert @invited_email.valid?
    end

    should_validate_presence_of :email

    should "not have an accepted_at" do
      assert_nil @invited_email.accepted_at
    end
  end

  context "an accepted email" do
    setup do
      @accepted_invited_email = Factory(:invited_email)
      @accepted_invited_email.accept!
    end

    should "have an accepted_at" do
      assert_not_nil @accepted_invited_email.accepted_at
    end
  end

  context 'with accepted an unaccepted emails' do
    setup do
      @accepteds = [Factory(:invited_email, :accepted_at => Time.now),
                    Factory(:invited_email, :accepted_at => Time.now)]

      @unaccepteds = [Factory(:invited_email), Factory(:invited_email)]
    end

    should "return only accepteds when sent #accepted" do
      assert_same_elements @accepteds, InvitedEmail.accepted
    end
  end
end
