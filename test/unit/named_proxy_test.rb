require 'test_helper'

class NamedProxyTest < ActiveSupport::TestCase
  context 'a named proxy' do
    setup do
      @proxy = Factory(:named_proxy)
    end
    should_belong_to :user

    should_ensure_length_in_range :name, (3..100)

    should_ensure_length_in_range :email, (6..100)
    should_validate_uniqueness_of :email, :scoped_to => :user_id

    should "have a valid factory" do
      assert_valid Factory(:named_proxy)
    end
  end

  test "validation" do
    proxy = NamedProxy.new
    assert !proxy.save
    assert proxy.errors.on(:email).any? { |e| e =~ /is invalid/i }
  end
end
