require 'test_helper'

class NamedProxyTest < ActiveSupport::TestCase
  context 'a named proxy' do
    setup do
      @proxy = Factory(:named_proxy)
    end
    should belong_to :user

    should ensure_length_of(:name).is_at_least(3).is_at_most(100)
    should ensure_length_of(:email).is_at_least(6).is_at_most(100)
    should validate_uniqueness_of(:email).scoped_to(:user_id)

    should "have a valid factory" do
      assert_valid Factory(:named_proxy)
    end
  end

  test "validation" do
    proxy = NamedProxy.new
    assert !proxy.save
    assert proxy.errors[:email].any? { |e| e =~ /is invalid/i }
  end
end
