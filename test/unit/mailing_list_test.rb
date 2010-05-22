require 'test_helper'

class MailingListTest < Test::Unit::TestCase
  context 'a mailing list' do
    setup do
      @mailing_list = Factory(:mailing_list)
    end
    should_have_and_belong_to_many :users
    should_validate_uniqueness_of :name

    should "have a valid factory" do
      assert_valid Factory(:mailing_list)
    end
  end
end
